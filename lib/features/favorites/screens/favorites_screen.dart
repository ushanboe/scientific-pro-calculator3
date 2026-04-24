// Step 1: Inventory
// This file DEFINES: FavoritesScreen (StatefulWidget + State)
// State variables: _favoritesList (List<FavoriteItem>), _isLoading (bool)
// Methods: _loadFavorites(), _reorderFavorites(), _removeFavorite(), _showAddFavoriteDialog(), _navigateToConstants()
// Imports needed: flutter/material.dart, FavoriteItem model, FavoritesService, ConstantsScreen
//
// Step 2: Connections
// - FavoritesService.getAllFavorites() → populate _favoritesList on load
// - FavoritesService.removeFavorite(id) → remove item
// - FavoritesService.updateFavoritesOrder(items) → after reorder
// - FavoritesService.addFavorite() → from add dialog
// - ConstantsService.search() → for add dialog constants tab
// - Navigate to ConstantsScreen via Navigator.push
// - PhysicalConstant model for add dialog
//
// Step 3: User Journey Trace
// Screen loads → _loadFavorites() → FavoritesService.getAllFavorites() → setState favoritesList
// Empty state: user sees icon + text + Browse Constants button → taps → Navigator.push(ConstantsScreen)
// Non-empty: ReorderableListView shows items with drag handles
// Drag handle → reorder → _reorderFavorites() → update sortOrder → FavoritesService.updateFavoritesOrder()
// X button → _removeFavorite() → FavoritesService.removeFavorite() → remove from list
// + AppBar button → _showAddFavoriteDialog() → dialog with Constants/Units tabs → select → addFavorite() → reload
//
// Step 4: Layout Sanity
// ReorderableListView.builder inside SafeArea — no unbounded height issues
// Dialog uses DefaultTabController with TabBarView — constrained height via SizedBox
// All callbacks are real implementations

import 'package:flutter/material.dart';
import 'package:scientific_pro_calculator/models/favorite_item.dart';
import 'package:scientific_pro_calculator/models/physical_constant.dart';
import 'package:scientific_pro_calculator/services/favorites_service.dart';
import 'package:scientific_pro_calculator/services/constants_service.dart';
import 'package:scientific_pro_calculator/features/constants/screens/constants_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> _favoritesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final items = await FavoritesService.instance.getAllFavorites();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      if (mounted) {
        setState(() {
          _favoritesList = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reorderFavorites(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final updated = List<FavoriteItem>.from(_favoritesList);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    final reordered = <FavoriteItem>[];
    for (int i = 0; i < updated.length; i++) {
      reordered.add(updated[i].copyWith(sortOrder: i));
    }

    setState(() {
      _favoritesList = reordered;
    });

    try {
      await FavoritesService.instance.updateFavoritesOrder(reordered);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save order: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    try {
      await FavoritesService.instance.removeFavorite(item.id);
      setState(() {
        _favoritesList.removeWhere((f) => f.id == item.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.label} removed from favorites',
              style: const TextStyle(color: Color(0xFFE2E8F0)),
            ),
            backgroundColor: const Color(0xFF293548),
            action: SnackBarAction(
              label: 'Undo',
              textColor: const Color(0xFF4C6EF5),
              onPressed: () async {
                try {
                  final restored = await FavoritesService.instance.addFavorite(
                    type: item.type,
                    label: item.label,
                    value: item.value,
                    unit: item.unit ?? '',
                    category: item.category ?? '',
                  );
                  await _loadFavorites();
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    }
  }

  void _navigateToConstants() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConstantsScreen()),
    ).then((_) => _loadFavorites());
  }

  void _showAddFavoriteDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddFavoriteDialog(
        onAdded: () => _loadFavorites(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add favorite',
            onPressed: _showAddFavoriteDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
                ),
              )
            : _favoritesList.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_outline_rounded,
            size: 48,
            color: Color(0xFF64748B),
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF94A3B8),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Star items from Constants, Units, or Calculator',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToConstants,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C6EF5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Constants'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ReorderableListView.builder(
      onReorder: _reorderFavorites,
      itemCount: _favoritesList.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = _favoritesList[index];
        return _FavoriteItemCard(
          key: ValueKey(item.id),
          item: item,
          index: index,
          onRemove: () => _removeFavorite(item),
        );
      },
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;
  final int index;
  final VoidCallback onRemove;

  const _FavoriteItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
  });

  IconData _getTypeIcon() {
    switch (item.type) {
      case 'constant':
        return Icons.science_rounded;
      case 'unit_conversion':
        return Icons.straighten_rounded;
      case 'function':
        return Icons.functions_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueDisplay = item.value +
        ((item.unit != null && item.unit!.isNotEmpty)
            ? ' ${item.unit}'
            : '');
    final categoryDisplay = item.category ?? item.type;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.drag_handle_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4C6EF5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getTypeIcon(),
              size: 16,
              color: const Color(0xFF4C6EF5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'Roboto Mono',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  categoryDisplay,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onRemove,
            color: const Color(0xFFEF4444),
            tooltip: 'Remove',
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _AddFavoriteDialog extends StatefulWidget {
  final VoidCallback onAdded;

  const _AddFavoriteDialog({required this.onAdded});

  @override
  State<_AddFavoriteDialog> createState() => _AddFavoriteDialogState();
}

class _AddFavoriteDialogState extends State<_AddFavoriteDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<PhysicalConstant> _constants = [];
  List<PhysicalConstant> _filteredConstants = [];
  bool _isLoadingConstants = true;

  // Built-in unit conversions for quick-add
  final List<_UnitConversionEntry> _unitConversions = const [
    _UnitConversionEntry(label: 'km → m', value: '1000', unit: 'm', category: 'Length'),
    _UnitConversionEntry(label: 'm → ft', value: '3.28084', unit: 'ft', category: 'Length'),
    _UnitConversionEntry(label: 'kg → lb', value: '2.20462', unit: 'lb', category: 'Mass'),
    _UnitConversionEntry(label: 'lb → kg', value: '0.453592', unit: 'kg', category: 'Mass'),
    _UnitConversionEntry(label: '°C → °F', value: 'x*9/5+32', unit: '°F', category: 'Temperature'),
    _UnitConversionEntry(label: 'L → gal', value: '0.264172', unit: 'gal', category: 'Volume'),
    _UnitConversionEntry(label: 'mi → km', value: '1.60934', unit: 'km', category: 'Length'),
    _UnitConversionEntry(label: 'in → cm', value: '2.54', unit: 'cm', category: 'Length'),
    _UnitConversionEntry(label: 'oz → g', value: '28.3495', unit: 'g', category: 'Mass'),
    _UnitConversionEntry(label: 'kPa → psi', value: '0.145038', unit: 'psi', category: 'Pressure'),
    _UnitConversionEntry(label: 'J → cal', value: '0.239006', unit: 'cal', category: 'Energy'),
    _UnitConversionEntry(label: 'W → BTU/h', value: '3.41214', unit: 'BTU/h', category: 'Power'),
  ];
  List<_UnitConversionEntry> _filteredUnits = [];
  final TextEditingController _unitSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredUnits = List.from(_unitConversions);
    _loadConstants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _unitSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadConstants() async {
    try {
      final constants = await ConstantsService.instance.getAllConstants();
      if (mounted) {
        setState(() {
          _constants = constants;
          _filteredConstants = constants;
          _isLoadingConstants = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingConstants = false;
        });
      }
    }
  }

  void _filterConstants(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredConstants = _constants;
      } else {
        _filteredConstants = _constants.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.symbol.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _filterUnits(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredUnits = List.from(_unitConversions);
      } else {
        _filteredUnits = _unitConversions.where((u) {
          return u.label.toLowerCase().contains(q) ||
              u.category.toLowerCase().contains(q) ||
              u.unit.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _addConstantFavorite(PhysicalConstant constant) async {
    try {
      await FavoritesService.instance.addFavorite(
        type: 'constant',
        label: constant.symbol,
        value: constant.value,
        unit: constant.unit,
        category: constant.category,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${constant.symbol} added to favorites',
              style: const TextStyle(color: Color(0xFFE2E8F0)),
            ),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    }
  }

  Future<void> _addUnitFavorite(_UnitConversionEntry entry) async {
    try {
      await FavoritesService.instance.addFavorite(
        type: 'unit_conversion',
        label: entry.label,
        value: entry.value,
        unit: entry.unit,
        category: entry.category,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${entry.label} added to favorites',
              style: const TextStyle(color: Color(0xFFE2E8F0)),
            ),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF293548),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  const Text(
                    'Add Favorite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Constants'),
                Tab(text: 'Units'),
              ],
              labelColor: const Color(0xFF4C6EF5),
              unselectedLabelColor: const Color(0xFF94A3B8),
              indicatorColor: const Color(0xFF4C6EF5),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildConstantsTab(),
                  _buildUnitsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConstantsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _filterConstants,
            style: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            decoration: InputDecoration(
              hintText: 'Search constants...',
              hintStyle: const TextStyle(
                  color: Color(0xFF64748B), fontFamily: 'Roboto'),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFF293548),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF4C6EF5), width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoadingConstants
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
                  ),
                )
              : _filteredConstants.isEmpty
                  ? const Center(
                      child: Text(
                        'No constants found',
                        style: TextStyle(
                            color: Color(0xFF94A3B8), fontFamily: 'Roboto'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredConstants.length,
                      itemBuilder: (context, index) {
                        final c = _filteredConstants[index];
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C6EF5).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                c.symbol.length <= 3 ? c.symbol : c.symbol.substring(0, 3),
                                style: const TextStyle(
                                  color: Color(0xFF4C6EF5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Roboto Mono',
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          subtitle: Text(
                            '${c.value} ${c.unit}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontFamily: 'Roboto Mono',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.star_outline_rounded,
                                color: Color(0xFFF59E0B), size: 20),
                            onPressed: () => _addConstantFavorite(c),
                            tooltip: 'Add to favorites',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                          onTap: () => _addConstantFavorite(c),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUnitsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _unitSearchController,
            onChanged: _filterUnits,
            style: const TextStyle(color: Colors.white, fontFamily: 'Roboto'),
            decoration: InputDecoration(
              hintText: 'Search conversions...',
              hintStyle: const TextStyle(
                  color: Color(0xFF64748B), fontFamily: 'Roboto'),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFF293548),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF4C6EF5), width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredUnits.isEmpty
              ? const Center(
                  child: Text(
                    'No conversions found',
                    style: TextStyle(
                        color: Color(0xFF94A3B8), fontFamily: 'Roboto'),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredUnits.length,
                  itemBuilder: (context, index) {
                    final u = _filteredUnits[index];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.straighten_rounded,
                          color: Color(0xFF14B8A6),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        u.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      subtitle: Text(
                        '${u.value} ${u.unit} · ${u.category}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontFamily: 'Roboto Mono',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.star_outline_rounded,
                            color: Color(0xFFF59E0B), size: 20),
                        onPressed: () => _addUnitFavorite(u),
                        tooltip: 'Add to favorites',
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      onTap: () => _addUnitFavorite(u),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _UnitConversionEntry {
  final String label;
  final String value;
  final String unit;
  final String category;

  const _UnitConversionEntry({
    required this.label,
    required this.value,
    required this.unit,
    required this.category,
  });
}