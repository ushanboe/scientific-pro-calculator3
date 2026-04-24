// Step 1: Inventory
// This file DEFINES: SavedMatrix class with fields:
//   - id (int, non-nullable) — Unique ID
//   - name (String, non-nullable) — Matrix slot name (A, B, C, etc.)
//   - rows (int, non-nullable) — Number of rows
//   - cols (int, non-nullable) — Number of columns
//   - data (String, non-nullable) — JSON-serialized matrix data
//   - createdAt (DateTime, non-nullable) — When matrix was created
//   - updatedAt (DateTime, non-nullable) — Last update timestamp
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: matrix_vector_service.dart, saved_matrices_provider.dart, matrix_vector_screen.dart
// toMap/fromMap → SQLite persistence via HistoryService (matrices table)
// toJson/fromJson → export and serialization
// copyWith → provider state updates
// data field stores JSON-serialized List<List<double>> or similar structure
//
// Step 3: User Journey Trace
// MatrixVectorScreen user saves matrix → SavedMatricesProvider.saveMatrix() creates SavedMatrix
// Service calls toMap() to insert into SQLite
// Service calls fromMap() to reconstruct from SQLite rows
// MatrixVectorScreen load button → provider retrieves SavedMatrix, uses data field to restore matrix
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// createdAt and updatedAt stored as ISO8601 strings in SQLite
// id uses null in toMap() when 0 to allow AUTOINCREMENT, matching CalculationHistory pattern
// Follows exact same pattern as CalculationHistory, FavoriteItem, PhysicalConstant

class SavedMatrix {
  final int id;
  final String name;
  final int rows;
  final int cols;
  final String data;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedMatrix({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  SavedMatrix copyWith({
    int? id,
    String? name,
    int? rows,
    int? cols,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedMatrix(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rows': rows,
      'cols': cols,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedMatrix.fromJson(Map<String, dynamic> json) {
    return SavedMatrix(
      id: json['id'] as int,
      name: json['name'] as String,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      data: json['data'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'name': name,
      'rows': rows,
      'cols': cols,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavedMatrix.fromMap(Map<String, dynamic> map) {
    return SavedMatrix(
      id: map['id'] as int,
      name: map['name'] as String,
      rows: map['rows'] as int,
      cols: map['cols'] as int,
      data: map['data'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'SavedMatrix(id: $id, name: $name, rows: $rows, cols: $cols, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedMatrix && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}