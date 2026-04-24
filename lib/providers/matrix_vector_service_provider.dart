// Step 1: Inventory
// This file DEFINES: matrixVectorServiceProvider (Provider<MatrixVectorService>)
// It USES: MatrixVectorService from lib/services/matrix_vector_service.dart
// Import needed: package:flutter_riverpod/flutter_riverpod.dart
// Import needed: package:scientific_pro_calculator/services/matrix_vector_service.dart
//
// Step 2: Connections
// This provider is consumed by matrix_vector_screen.dart
// It simply exposes the MatrixVectorService.instance singleton
// No navigation, no database, no SharedPreferences needed
//
// Step 3: User Journey Trace
// MatrixVectorScreen calls ref.watch(matrixVectorServiceProvider) to get the service
// Then calls service methods like matrixMultiply, eigenvalues, luDecomposition, etc.
// The provider is read-only (Provider, not StateNotifierProvider) — just returns the singleton
//
// Step 4: Layout Sanity
// Pure provider file — no widgets, no layout concerns
// Pattern matches other service providers in this project (arithmetic_service_provider, etc.)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/services/matrix_vector_service.dart';

final matrixVectorServiceProvider = Provider<MatrixVectorService>((ref) {
  return MatrixVectorService.instance;
});