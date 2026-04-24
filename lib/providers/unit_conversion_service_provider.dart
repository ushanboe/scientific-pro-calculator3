// Step 1: Inventory
// This file DEFINES: unitConversionServiceProvider — a Riverpod Provider<UnitConversionService>
//   that returns the singleton UnitConversionService instance.
// It USES: UnitConversionService from lib/services/unit_conversion_service.dart
//
// Step 2: Connections
// Imported by: lib/features/units/screens/units_screen.dart (watches this provider to get service)
// Depends on: lib/services/unit_conversion_service.dart (UnitConversionService.instance)
//
// Step 3: User Journey Trace
// UnitsScreen calls ref.watch(unitConversionServiceProvider) → gets UnitConversionService singleton
// Service is used to call convert(), search(), getUnitsByCategory(), getAllCategories()
//
// Step 4: Layout Sanity
// Pure provider file — no widgets, no layout concerns
// Simple Provider<UnitConversionService> returning the singleton instance

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/unit_conversion_service.dart';

final unitConversionServiceProvider = Provider<UnitConversionService>((ref) {
  return UnitConversionService.instance;
});