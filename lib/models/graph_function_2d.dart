// Step 1: Inventory
// This file DEFINES: GraphFunction2D class with fields:
//   - expression (String, non-nullable) — Function expression e.g. 'x^2'
//   - color (Color, non-nullable) — Color to draw curve
//   - label (String?, nullable) — Optional label for legend
// Methods: copyWith
// Needs import: package:flutter/material.dart for Color
//
// Step 2: Connections
// Used by: graphing_service.dart, graph_screen.dart, saved_graphs_provider.dart
// No imports from other project files needed — pure data model
// Color type comes from flutter/material.dart
//
// Step 3: User Journey Trace
// GraphScreen creates GraphFunction2D with expression, color, label
// GraphingService.generatePlotData() uses expression field to evaluate function
// Graph canvas uses color field to draw the curve
// Legend uses label field (if non-null) to display function name
//
// Step 4: Layout Sanity
// Pure data model — no widgets, no layout concerns
// Follows exact same pattern as other models: CalculationHistory, FavoriteItem, etc.
// Color is stored as-is (in-memory model, not persisted directly — SavedGraph stores JSON of expressions)
// copyWith handles nullable label correctly using explicit sentinel pattern

import 'package:flutter/material.dart';

class GraphFunction2D {
  final String expression;
  final Color color;
  final String? label;

  const GraphFunction2D({
    required this.expression,
    required this.color,
    this.label,
  });

  GraphFunction2D copyWith({
    String? expression,
    Color? color,
    String? label,
    bool clearLabel = false,
  }) {
    return GraphFunction2D(
      expression: expression ?? this.expression,
      color: color ?? this.color,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  @override
  String toString() {
    return 'GraphFunction2D(expression: $expression, color: $color, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphFunction2D &&
        other.expression == expression &&
        other.color == color &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(expression, color, label);
}