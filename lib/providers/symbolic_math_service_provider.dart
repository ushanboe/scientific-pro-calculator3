// Step 1: Inventory
// This file DEFINES: symbolicMathServiceProvider (Provider<SymbolicMathService>)
// It USES: SymbolicMathService from lib/services/symbolic_math_service.dart
// Riverpod 2.x pattern: use Provider (not StateNotifierProvider) since SymbolicMathService is a singleton
//
// Step 2: Connections
// SymbolicMathService.instance is already a singleton via the private constructor pattern
// Provider simply exposes it to the Riverpod tree
// Used by: symbolic_screen.dart, equation_solver_screen.dart, graph_screen.dart
//
// Step 3: User Journey Trace
// Any ConsumerWidget calls ref.watch(symbolicMathServiceProvider) to get the service instance
// Then calls methods like derivative(), integralIndefinite(), etc.
//
// Step 4: Layout Sanity
// Pure provider file — no widgets, no layout

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/symbolic_math_service.dart';

final symbolicMathServiceProvider = Provider<SymbolicMathService>((ref) {
  return SymbolicMathService.instance;
});