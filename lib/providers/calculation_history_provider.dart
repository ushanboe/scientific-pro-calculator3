import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/calculation_history.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';

class CalculationHistoryNotifier extends AsyncNotifier<List<CalculationHistory>> {
  @override
  Future<List<CalculationHistory>> build() async {
    try {
      return await HistoryService.instance.getAllHistory();
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC loadHistory error: $e');
      return [];
    }
  }

  Future<void> loadHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => HistoryService.instance.getAllHistory());
  }

  Future<void> addCalculation(CalculationHistory entry) async {
    try {
      final saved = await HistoryService.instance.addCalculation(entry);
      final current = state.value ?? [];
      state = AsyncData([saved, ...current]);
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC addCalculation error: $e');
    }
  }

  Future<void> deleteCalculation(int id) async {
    try {
      await HistoryService.instance.deleteCalculation(id);
      final current = state.value ?? [];
      state = AsyncData(current.where((e) => e.id != id).toList());
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC deleteCalculation error: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await HistoryService.instance.clearHistory();
      state = const AsyncData([]);
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC clearHistory error: $e');
    }
  }

  Future<void> searchHistory(String query) async {
    try {
      if (query.trim().isEmpty) {
        await loadHistory();
        return;
      }
      final results = await HistoryService.instance.searchHistory(query);
      state = AsyncData(results);
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC searchHistory error: $e');
    }
  }
}

final calculationHistoryProvider =
    AsyncNotifierProvider<CalculationHistoryNotifier, List<CalculationHistory>>(
  CalculationHistoryNotifier.new,
);
