import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/saved_graph.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';

class SavedGraphsNotifier extends Notifier<List<SavedGraph>> {
  @override
  List<SavedGraph> build() {
    listAllGraphs();
    return const [];
  }

  Future<SavedGraph> saveGraph(SavedGraph graph) async {
    try {
      final saved = await HistoryService.instance.saveGraph(graph);
      final currentList = List<SavedGraph>.from(state);
      final existingIndex = currentList.indexWhere((g) => g.id == saved.id);
      if (existingIndex >= 0) {
        currentList[existingIndex] = saved;
      } else {
        currentList.insert(0, saved);
      }
      state = List<SavedGraph>.unmodifiable(currentList);
      return saved;
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC saveGraph error: $e');
      rethrow;
    }
  }

  Future<SavedGraph?> loadGraph(int id) async {
    try {
      return await HistoryService.instance.loadGraph(id);
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC loadGraph error: $e');
      return null;
    }
  }

  Future<void> deleteGraph(int id) async {
    try {
      await HistoryService.instance.deleteGraph(id);
      state = List<SavedGraph>.unmodifiable(
        state.where((g) => g.id != id).toList(),
      );
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC deleteGraph error: $e');
      rethrow;
    }
  }

  Future<void> listAllGraphs() async {
    try {
      final graphs = await HistoryService.instance.getAllGraphs();
      state = List<SavedGraph>.unmodifiable(graphs);
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC listAllGraphs error: $e');
      state = const [];
    }
  }
}

final savedGraphsProvider =
    NotifierProvider<SavedGraphsNotifier, List<SavedGraph>>(
  SavedGraphsNotifier.new,
);
