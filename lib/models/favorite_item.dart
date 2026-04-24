// Step 1: Inventory
// This file DEFINES: FavoriteItem class with fields:
//   - id (int, non-nullable)
//   - type (String, non-nullable) — 'function', 'constant', 'unit_conversion'
//   - label (String, non-nullable) — display label
//   - value (String, non-nullable) — actual value or expression
//   - unit (String?, nullable) — unit string if applicable
//   - category (String?, nullable) — category for organizing
//   - sortOrder (int, non-nullable) — order in toolbar
//   - createdAt (DateTime, non-nullable) — when added
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: favorites_service.dart, favorites_provider.dart, favorites_screen.dart,
//          calculator_screen.dart, constants_screen.dart, units_screen.dart
// toMap/fromMap → SQLite persistence via FavoritesService
// toJson/fromJson → export via ExportService
// copyWith → provider state updates
//
// Step 3: User Journey Trace
// ConstantsScreen stars a constant → FavoritesProvider.addFavorite() creates FavoriteItem
// FavoritesService.addFavorite() calls toMap() to insert into SQLite
// FavoritesService.getAllFavorites() calls fromMap() to reconstruct from SQLite rows
// FavoritesScreen displays favorites using label, value, unit, type, category fields
// Drag-to-reorder updates sortOrder field
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// createdAt stored as ISO8601 string in SQLite, parsed back via DateTime.parse()
// id uses null in toMap() when 0 to allow AUTOINCREMENT, matching CalculationHistory pattern
// Boolean fields: none needed here
// Nullable fields unit and category map to nullable TEXT in SQLite

class FavoriteItem {
  final int id;
  final String type;
  final String label;
  final String value;
  final String? unit;
  final String? category;
  final int sortOrder;
  final DateTime createdAt;

  const FavoriteItem({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    this.unit,
    this.category,
    required this.sortOrder,
    required this.createdAt,
  });

  FavoriteItem copyWith({
    int? id,
    String? type,
    String? label,
    String? value,
    String? unit,
    String? category,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'value': value,
      'unit': unit,
      'category': category,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as int,
      type: json['type'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'type': type,
      'label': label,
      'value': value,
      'unit': unit,
      'category': category,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] as int,
      type: map['type'] as String,
      label: map['label'] as String,
      value: map['value'] as String,
      unit: map['unit'] as String?,
      category: map['category'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'FavoriteItem(id: $id, type: $type, label: $label, value: $value, '
        'unit: $unit, category: $category, sortOrder: $sortOrder, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}