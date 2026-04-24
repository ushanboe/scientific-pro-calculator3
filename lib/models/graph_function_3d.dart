// Step 1: Inventory
// This file DEFINES: GraphFunction3D class with fields:
//   - expression (String, non-nullable) — 3D surface expression e.g. 'x^2 + y^2'
//   - uMin (double, non-nullable) — Minimum u parameter
//   - uMax (double, non-nullable) — Maximum u parameter
//   - vMin (double, non-nullable) — Minimum v parameter
//   - vMax (double, non-nullable) — Maximum v parameter
//   - meshDensity (int, non-nullable) — Number of subdivisions per axis (10-100)
//   - isParametric (bool, non-nullable) — Whether to use parametric form
// Methods: copyWith
// No imports from other project files needed — pure data model
// No flutter imports needed — no Color or widget types
//
// Step 2: Connections
// Used by: graphing_service.dart, graph_screen.dart, saved_graphs_provider.dart
// No navigation, no services, no providers needed here
// Pattern matches GraphFunction2D exactly but without Color field
//
// Step 3: User Journey Trace
// GraphScreen creates GraphFunction3D with expression, parameter ranges, meshDensity, isParametric
// GraphingService uses expression + uMin/uMax/vMin/vMax + meshDensity to compute 3D surface mesh
// isParametric flag determines whether expression is f(x,y)=z form or parametric (u,v) → (x,y,z)
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// copyWith handles all fields correctly
// Follows exact same pattern as GraphFunction2D and other models in this project

class GraphFunction3D {
  final String expression;
  final double uMin;
  final double uMax;
  final double vMin;
  final double vMax;
  final int meshDensity;
  final bool isParametric;

  const GraphFunction3D({
    required this.expression,
    required this.uMin,
    required this.uMax,
    required this.vMin,
    required this.vMax,
    required this.meshDensity,
    required this.isParametric,
  });

  GraphFunction3D copyWith({
    String? expression,
    double? uMin,
    double? uMax,
    double? vMin,
    double? vMax,
    int? meshDensity,
    bool? isParametric,
  }) {
    return GraphFunction3D(
      expression: expression ?? this.expression,
      uMin: uMin ?? this.uMin,
      uMax: uMax ?? this.uMax,
      vMin: vMin ?? this.vMin,
      vMax: vMax ?? this.vMax,
      meshDensity: meshDensity ?? this.meshDensity,
      isParametric: isParametric ?? this.isParametric,
    );
  }

  @override
  String toString() {
    return 'GraphFunction3D(expression: $expression, uMin: $uMin, uMax: $uMax, '
        'vMin: $vMin, vMax: $vMax, meshDensity: $meshDensity, isParametric: $isParametric)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphFunction3D &&
        other.expression == expression &&
        other.uMin == uMin &&
        other.uMax == uMax &&
        other.vMin == vMin &&
        other.vMax == vMax &&
        other.meshDensity == meshDensity &&
        other.isParametric == isParametric;
  }

  @override
  int get hashCode => Object.hash(
        expression,
        uMin,
        uMax,
        vMin,
        vMax,
        meshDensity,
        isParametric,
      );
}