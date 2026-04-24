// Step 1: Inventory
// This file DEFINES: graphingServiceProvider — a Riverpod Provider<GraphingService>
// It returns the singleton GraphingService.instance
// Imports needed: flutter_riverpod, GraphingService from services/graphing_service.dart
//
// Step 2: Connections
// GraphingService.instance is the singleton defined in graphing_service.dart
// This provider will be used by graph_screen.dart via ref.watch(graphingServiceProvider)
// Pattern matches other service providers in this project (arithmetic_service_provider, etc.)
//
// Step 3: User Journey Trace
// GraphScreen calls ref.watch(graphingServiceProvider) to get the GraphingService instance
// Provider simply returns GraphingService.instance — no state, no notifier needed
// Pure Provider<GraphingService> (not StateNotifierProvider)
//
// Step 4: Layout Sanity
// No widgets — pure provider file
// Use Riverpod 2.x pattern: top-level Provider variable

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/graphing_service.dart';

final graphingServiceProvider = Provider<GraphingService>((ref) {
  return GraphingService.instance;
});