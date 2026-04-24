// Step 1: Inventory
// This file DEFINES: PhysicalConstant class with fields:
//   - id (int, non-nullable)
//   - name (String, non-nullable) — Full name e.g. 'Planck Constant'
//   - symbol (String, non-nullable) — Symbol e.g. 'h'
//   - value (String, non-nullable) — High-precision string value
//   - unit (String, non-nullable) — SI unit
//   - uncertainty (String?, nullable) — Uncertainty value
//   - category (String, non-nullable) — Category: Universal, Electromagnetic, Atomic, Thermodynamic, Gravitational
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: constants_service.dart, constants_screen.dart, favorites_provider.dart
// toMap/fromMap → SQLite persistence via ConstantsService (seeded from JSON asset)
// toJson/fromJson → export via ExportService
// copyWith → provider/service state updates
// The id field uses non-null int — constants are seeded with explicit IDs from JSON
//
// Step 3: User Journey Trace
// ConstantsService.seedDatabaseIfNeeded() reads physical_constants.json →
//   creates PhysicalConstant.fromJson() → calls toMap() → inserts into SQLite
// ConstantsService.search() queries SQLite → calls fromMap() → returns List<PhysicalConstant>
// ConstantsScreen displays name, symbol, value, unit, category fields
// FavoritesProvider.addFavorite() uses symbol as label, value as value, unit as unit
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// id field is non-nullable int (constants have explicit IDs from JSON, unlike history which uses AUTOINCREMENT)
// In toMap(), id is always included (no null check needed — constants always have explicit IDs)
// uncertainty is nullable — some constants have exact values with no uncertainty
// Pattern matches CalculationHistory and FavoriteItem exactly for consistency

class PhysicalConstant {
  final int id;
  final String name;
  final String symbol;
  final String value;
  final String unit;
  final String? uncertainty;
  final String category;

  const PhysicalConstant({
    required this.id,
    required this.name,
    required this.symbol,
    required this.value,
    required this.unit,
    this.uncertainty,
    required this.category,
  });

  PhysicalConstant copyWith({
    int? id,
    String? name,
    String? symbol,
    String? value,
    String? unit,
    String? uncertainty,
    String? category,
  }) {
    return PhysicalConstant(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      uncertainty: uncertainty ?? this.uncertainty,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'value': value,
      'unit': unit,
      'uncertainty': uncertainty,
      'category': category,
    };
  }

  factory PhysicalConstant.fromJson(Map<String, dynamic> json) {
    return PhysicalConstant(
      id: json['id'] as int,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      uncertainty: json['uncertainty'] as String?,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'value': value,
      'unit': unit,
      'uncertainty': uncertainty,
      'category': category,
    };
  }

  factory PhysicalConstant.fromMap(Map<String, dynamic> map) {
    return PhysicalConstant(
      id: map['id'] as int,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      value: map['value'] as String,
      unit: map['unit'] as String,
      uncertainty: map['uncertainty'] as String?,
      category: map['category'] as String,
    );
  }

  @override
  String toString() {
    return 'PhysicalConstant(id: $id, name: $name, symbol: $symbol, '
        'value: $value, unit: $unit, uncertainty: $uncertainty, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhysicalConstant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}