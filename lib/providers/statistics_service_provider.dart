// Step 1: Inventory
// This file DEFINES: statisticsServiceProvider — a Provider<StatisticsService> that returns the singleton instance
// It USES: StatisticsService from lib/services/statistics_service.dart
// Import: package:flutter_riverpod/flutter_riverpod.dart for Provider
// Import: package:scientific_pro_calculator/services/statistics_service.dart for StatisticsService
//
// Step 2: Connections
// This provider is consumed by: stats_screen.dart (ref.watch(statisticsServiceProvider))
// It wraps: StatisticsService.instance (singleton)
// No navigation needed — pure service provider
//
// Step 3: User Journey Trace
// StatsScreen calls ref.watch(statisticsServiceProvider) → gets StatisticsService singleton
// StatsScreen calls .descriptiveStats(), .pdfCdf(), .hypothesisTest(), .regression() on it
// Provider just returns the pre-constructed singleton — no async init needed
//
// Step 4: Layout Sanity
// No widgets — pure provider file
// Pattern matches other service providers in this project (arithmetic_service_provider, etc.)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/statistics_service.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService.instance;
});