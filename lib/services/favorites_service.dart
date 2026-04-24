import 'package:scientific_pro_calculator/models/favorite_item.dart';

class FavoritesService {
  static final FavoritesService instance = FavoritesService._();
  FavoritesService._();

  final List<FavoriteItem> _favorites = [];
  int _nextId = 1;

  Future<List<FavoriteItem>> getAllFavorites() async {
    return List<FavoriteItem>.from(_favorites);
  }

  Future<FavoriteItem?> addFavorite({
    required String type,
    required String label,
    required String value,
    String unit = '',
    String category = '',
  }) async {
    final item = FavoriteItem(
      id: _nextId++,
      type: type,
      label: label,
      value: value,
      unit: unit.isEmpty ? null : unit,
      category: category.isEmpty ? null : category,
      sortOrder: _favorites.length,
      createdAt: DateTime.now(),
    );
    _favorites.add(item);
    return item;
  }

  Future<void> removeFavorite(int id) async {
    _favorites.removeWhere((f) => f.id == id);
  }

  Future<void> updateFavoritesOrder(List<FavoriteItem> reordered) async {
    _favorites.clear();
    _favorites.addAll(reordered);
  }
}