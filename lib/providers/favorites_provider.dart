import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scientific_pro_calculator/models/favorite_item.dart';
import 'package:scientific_pro_calculator/services/favorites_service.dart';

class FavoritesNotifier extends Notifier<List<FavoriteItem>> {
  @override
  List<FavoriteItem> build() {
    loadFavorites();
    return [];
  }

  Future<List<FavoriteItem>> loadFavorites() async {
    final items = await FavoritesService.instance.getAllFavorites();
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = items;
    return items;
  }

  Future<FavoriteItem?> addFavoriteItem(FavoriteItem item) async {
    try {
      final saved = await FavoritesService.instance.addFavorite(
        type: item.type,
        label: item.label,
        value: item.value,
        unit: item.unit ?? '',
        category: item.category ?? '',
      );
      if (saved != null) {
        state = [...state, saved];
        return saved;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeFavorite(int id) async {
    await FavoritesService.instance.removeFavorite(id);
    state = state.where((f) => f.id != id).toList();
  }

  Future<void> reorderFavorites(List<FavoriteItem> reordered) async {
    state = reordered;
    await FavoritesService.instance.updateFavoritesOrder(reordered);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<FavoriteItem>>(
  FavoritesNotifier.new,
);
