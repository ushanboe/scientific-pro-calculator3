import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/saved_matrix.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';

class SavedMatricesNotifier extends Notifier<Map<String, SavedMatrix>> {
  @override
  Map<String, SavedMatrix> build() {
    _loadAll();
    return const {};
  }

  Future<void> _loadAll() async {
    try {
      final matrices = await HistoryService.instance.getAllMatrices();
      final map = <String, SavedMatrix>{};
      for (final matrix in matrices) {
        map[matrix.name] = matrix;
      }
      state = map;
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC SavedMatricesNotifier._loadAll error: $e');
    }
  }

  Future<void> saveMatrix(String name, SavedMatrix matrix) async {
    try {
      final toSave = matrix.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );
      final saved = await HistoryService.instance.saveMatrix(toSave);
      final updated = Map<String, SavedMatrix>.from(state);
      updated[name] = saved;
      state = updated;
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC SavedMatricesNotifier.saveMatrix error: $e');
    }
  }

  SavedMatrix? loadMatrix(String name) {
    return state[name];
  }

  Future<void> deleteMatrix(String name) async {
    try {
      await HistoryService.instance.deleteMatrix(name);
      final updated = Map<String, SavedMatrix>.from(state);
      updated.remove(name);
      state = updated;
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC SavedMatricesNotifier.deleteMatrix error: $e');
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }
}

final savedMatricesProvider =
    NotifierProvider<SavedMatricesNotifier, Map<String, SavedMatrix>>(
  SavedMatricesNotifier.new,
);
