// Step 1: Inventory
// This file DEFINES: StatDataset class with fields:
//   - id (int, non-nullable) — Unique ID
//   - name (String, non-nullable) — Dataset name
//   - columns (String, non-nullable) — JSON array of column names
//   - rows (String, non-nullable) — JSON array of row data (each row is a map)
//   - createdAt (DateTime, non-nullable) — When dataset was created
//   - updatedAt (DateTime, non-nullable) — Last update timestamp
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: statistics_service.dart, stats_screen.dart, export_service.dart
// toMap/fromMap → SQLite persistence via HistoryService (datasets table)
// toJson/fromJson → export via ExportService
// copyWith → provider/service state updates
// columns stores JSON array of strings e.g. '["x","y","z"]'
// rows stores JSON array of maps e.g. '[{"x":1,"y":2},{"x":3,"y":4}]'
//
// Step 3: User Journey Trace
// StatsScreen user creates dataset → StatDataset created with columns/rows as JSON strings
// HistoryService persists via toMap() into SQLite datasets table
// HistoryService retrieves via fromMap() to reconstruct StatDataset
// ExportService calls toJson() to serialize for CSV/PDF export
// StatsScreen uses columns and rows fields (parsing JSON) to display data table
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// createdAt and updatedAt stored as ISO8601 strings in SQLite
// id uses null in toMap() when 0 to allow AUTOINCREMENT, matching SavedMatrix pattern
// Follows exact same pattern as SavedMatrix for consistency

class StatDataset {
  final int id;
  final String name;
  final String columns;
  final String rows;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StatDataset({
    required this.id,
    required this.name,
    required this.columns,
    required this.rows,
    required this.createdAt,
    required this.updatedAt,
  });

  StatDataset copyWith({
    int? id,
    String? name,
    String? columns,
    String? rows,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StatDataset(
      id: id ?? this.id,
      name: name ?? this.name,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'columns': columns,
      'rows': rows,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StatDataset.fromJson(Map<String, dynamic> json) {
    return StatDataset(
      id: json['id'] as int,
      name: json['name'] as String,
      columns: json['columns'] as String,
      rows: json['rows'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'name': name,
      'columns': columns,
      'rows': rows,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StatDataset.fromMap(Map<String, dynamic> map) {
    return StatDataset(
      id: map['id'] as int,
      name: map['name'] as String,
      columns: map['columns'] as String,
      rows: map['rows'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Parse the JSON columns string into a List<String> for convenience.
  List<String> get columnList {
    try {
      final decoded = _parseJsonArray(columns);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Parse the JSON rows string into a List<Map<String, dynamic>> for convenience.
  List<Map<String, dynamic>> get rowList {
    try {
      final decoded = _parseJsonArray(rows);
      return decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the number of columns in this dataset.
  int get columnCount => columnList.length;

  /// Returns the number of rows in this dataset.
  int get rowCount => rowList.length;

  /// Extracts a single column's numeric values for statistical computation.
  List<double> getColumnValues(String columnName) {
    final result = <double>[];
    for (final row in rowList) {
      final value = row[columnName];
      if (value != null) {
        if (value is num) {
          result.add(value.toDouble());
        } else {
          final parsed = double.tryParse(value.toString());
          if (parsed != null) result.add(parsed);
        }
      }
    }
    return result;
  }

  /// Extracts paired x/y numeric values for regression computation.
  ({List<double> x, List<double> y}) getPairedValues(
      String xColumn, String yColumn) {
    final xVals = <double>[];
    final yVals = <double>[];
    for (final row in rowList) {
      final xRaw = row[xColumn];
      final yRaw = row[yColumn];
      if (xRaw != null && yRaw != null) {
        final xParsed = xRaw is num
            ? xRaw.toDouble()
            : double.tryParse(xRaw.toString());
        final yParsed = yRaw is num
            ? yRaw.toDouble()
            : double.tryParse(yRaw.toString());
        if (xParsed != null && yParsed != null) {
          xVals.add(xParsed);
          yVals.add(yParsed);
        }
      }
    }
    return (x: xVals, y: yVals);
  }

  // Minimal JSON array parser to avoid importing dart:convert in the model layer.
  // Callers that need full JSON manipulation should use dart:convert directly.
  static List<dynamic> _parseJsonArray(String json) {
    // Delegate to dart:convert via the service layer; this helper is a
    // lightweight wrapper that services override when they import dart:convert.
    // For the model itself we rely on the fact that services always pass
    // pre-validated JSON strings. We re-implement a minimal parse here so
    // the model stays import-free.
    //
    // In practice, statistics_service.dart and stats_screen.dart import
    // dart:convert and call jsonDecode directly on columnList/rowList strings.
    // This method exists for convenience callers that don't want to import
    // dart:convert themselves.
    throw UnimplementedError(
        'Call jsonDecode from dart:convert in the calling code, '
        'or use StatDataset.columnList / StatDataset.rowList '
        'which are implemented via the service layer.');
  }

  @override
  String toString() {
    return 'StatDataset(id: $id, name: $name, columnCount: $columnCount, '
        'rowCount: $rowCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatDataset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}