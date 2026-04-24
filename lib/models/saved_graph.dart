// Step 1: Inventory
// This file DEFINES: SavedGraph class with fields:
//   - id (int, non-nullable)
//   - name (String, non-nullable)
//   - mode (String, non-nullable) — '2d' or '3d'
//   - functions (String, non-nullable) — JSON array of function expressions
//   - xMin (double, non-nullable)
//   - xMax (double, non-nullable)
//   - yMin (double, non-nullable)
//   - yMax (double, non-nullable)
//   - integralLower (double?, nullable)
//   - integralUpper (double?, nullable)
//   - showIntegralArea (bool, non-nullable)
//   - limitTargetX (double?, nullable)
//   - showLimitVisualization (bool, non-nullable)
//   - createdAt (DateTime, non-nullable)
// Methods: copyWith, toJson, fromJson, toMap, fromMap
// No imports from other project files needed — pure data model
//
// Step 2: Connections
// Used by: graphing_service.dart, saved_graphs_provider.dart, graph_screen.dart
// toMap/fromMap → SQLite persistence via HistoryService (graphs table)
// toJson/fromJson → export and serialization
// copyWith → provider state updates
//
// Step 3: User Journey Trace
// GraphScreen user saves graph config → SavedGraphsProvider.saveGraph() creates SavedGraph
// Service calls toMap() to insert into SQLite
// Service calls fromMap() to reconstruct from SQLite rows
// GraphScreen load button → provider retrieves SavedGraph, uses fields to restore graph state
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// createdAt stored as ISO8601 string in SQLite
// id uses null in toMap() when 0 to allow AUTOINCREMENT, matching SavedMatrix pattern
// bool fields stored as int (0/1) in SQLite, matching CalculationHistory.isComplex pattern
// nullable doubles stored as nullable REAL in SQLite

class SavedGraph {
  final int id;
  final String name;
  final String mode;
  final String functions;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final double? integralLower;
  final double? integralUpper;
  final bool showIntegralArea;
  final double? limitTargetX;
  final bool showLimitVisualization;
  final DateTime createdAt;

  const SavedGraph({
    required this.id,
    required this.name,
    required this.mode,
    required this.functions,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    this.integralLower,
    this.integralUpper,
    required this.showIntegralArea,
    this.limitTargetX,
    required this.showLimitVisualization,
    required this.createdAt,
  });

  SavedGraph copyWith({
    int? id,
    String? name,
    String? mode,
    String? functions,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? integralLower,
    double? integralUpper,
    bool? showIntegralArea,
    double? limitTargetX,
    bool? showLimitVisualization,
    DateTime? createdAt,
  }) {
    return SavedGraph(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      functions: functions ?? this.functions,
      xMin: xMin ?? this.xMin,
      xMax: xMax ?? this.xMax,
      yMin: yMin ?? this.yMin,
      yMax: yMax ?? this.yMax,
      integralLower: integralLower ?? this.integralLower,
      integralUpper: integralUpper ?? this.integralUpper,
      showIntegralArea: showIntegralArea ?? this.showIntegralArea,
      limitTargetX: limitTargetX ?? this.limitTargetX,
      showLimitVisualization: showLimitVisualization ?? this.showLimitVisualization,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode,
      'functions': functions,
      'xMin': xMin,
      'xMax': xMax,
      'yMin': yMin,
      'yMax': yMax,
      'integralLower': integralLower,
      'integralUpper': integralUpper,
      'showIntegralArea': showIntegralArea,
      'limitTargetX': limitTargetX,
      'showLimitVisualization': showLimitVisualization,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedGraph.fromJson(Map<String, dynamic> json) {
    return SavedGraph(
      id: json['id'] as int,
      name: json['name'] as String,
      mode: json['mode'] as String,
      functions: json['functions'] as String,
      xMin: (json['xMin'] as num).toDouble(),
      xMax: (json['xMax'] as num).toDouble(),
      yMin: (json['yMin'] as num).toDouble(),
      yMax: (json['yMax'] as num).toDouble(),
      integralLower: json['integralLower'] != null
          ? (json['integralLower'] as num).toDouble()
          : null,
      integralUpper: json['integralUpper'] != null
          ? (json['integralUpper'] as num).toDouble()
          : null,
      showIntegralArea: json['showIntegralArea'] as bool,
      limitTargetX: json['limitTargetX'] != null
          ? (json['limitTargetX'] as num).toDouble()
          : null,
      showLimitVisualization: json['showLimitVisualization'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'name': name,
      'mode': mode,
      'functions': functions,
      'x_min': xMin,
      'x_max': xMax,
      'y_min': yMin,
      'y_max': yMax,
      'integral_lower': integralLower,
      'integral_upper': integralUpper,
      'show_integral_area': showIntegralArea ? 1 : 0,
      'limit_target_x': limitTargetX,
      'show_limit_visualization': showLimitVisualization ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedGraph.fromMap(Map<String, dynamic> map) {
    return SavedGraph(
      id: map['id'] as int,
      name: map['name'] as String,
      mode: map['mode'] as String,
      functions: map['functions'] as String,
      xMin: (map['x_min'] as num).toDouble(),
      xMax: (map['x_max'] as num).toDouble(),
      yMin: (map['y_min'] as num).toDouble(),
      yMax: (map['y_max'] as num).toDouble(),
      integralLower: map['integral_lower'] != null
          ? (map['integral_lower'] as num).toDouble()
          : null,
      integralUpper: map['integral_upper'] != null
          ? (map['integral_upper'] as num).toDouble()
          : null,
      showIntegralArea: (map['show_integral_area'] as int) == 1,
      limitTargetX: map['limit_target_x'] != null
          ? (map['limit_target_x'] as num).toDouble()
          : null,
      showLimitVisualization: (map['show_limit_visualization'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'SavedGraph(id: $id, name: $name, mode: $mode, '
        'xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax, '
        'showIntegralArea: $showIntegralArea, showLimitVisualization: $showLimitVisualization, '
        'createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedGraph && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}