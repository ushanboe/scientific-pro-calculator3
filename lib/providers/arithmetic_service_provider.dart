// Step 1: Inventory
// This file DEFINES: arithmeticServiceProvider — a Riverpod Provider<ArithmeticService>
// that returns the singleton ArithmeticService.instance
//
// Step 2: Connections
// Imports: flutter_riverpod for Provider
// Imports: ArithmeticService from lib/services/arithmetic_service.dart
// ArithmeticService has a static `instance` field (singleton pattern confirmed in the service file)
//
// Step 3: User Journey Trace
// CalculatorScreen calls ref.watch(arithmeticServiceProvider) to get ArithmeticService
// Then calls .evaluate(expression, settings) on the returned instance
//
// Step 4: Layout Sanity
// Pure provider file — no widgets, no layout

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/arithmetic_service.dart';

final arithmeticServiceProvider = Provider<ArithmeticService>((ref) {
  return ArithmeticService.instance;
});