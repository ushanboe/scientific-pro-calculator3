import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scientific_pro_calculator/models/physical_constant.dart';
import 'package:scientific_pro_calculator/services/constants_service.dart';
import 'package:scientific_pro_calculator/services/favorites_service.dart';

class ConstantsScreen extends StatefulWidget {
  const ConstantsScreen({super.key});

  @override
  State<ConstantsScreen> createState() => _ConstantsScreenState();
}

class _ConstantsScreenState extends State<ConstantsScreen> {
  List<PhysicalConstant> allConstants = [];
  List<PhysicalConstant> filteredConstants = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  final List<String> categories = [
    'Universal',
    'Electromagnetic',
    'Atomic',
    'Thermodynamic',
    'Gravitational',
  ];
  String? selectedCategory;
  Set<int> favoriteConstantIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final constants = await ConstantsService.instance.getAllConstants();
      final favorites = await FavoritesService.instance.getAllFavorites();
      final favIds = <int>{};
      for (final fav in favorites) {
        if (fav.type == 'constant') {
          final match = constants.where((c) => c.symbol == fav.label);
          for (final c in match) {
            favIds.add(c.id);
          }
        }
      }
      if (mounted) {
        setState(() {
          allConstants = constants;
          filteredConstants = constants;
          favoriteConstantIds = favIds;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _filterConstants() {
    final query = searchQuery.toLowerCase();
    setState(() {
      filteredConstants = allConstants.where((c) {
        final matchesSearch = query.isEmpty ||
            c.name.toLowerCase().contains(query) ||
            c.symbol.toLowerCase().contains(query) ||
            c.category.toLowerCase().contains(query);
        final matchesCategory =
            selectedCategory == null || c.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _filterConstants();
  }

  void _setCategory(String? cat) {
    setState(() {
      selectedCategory = cat;
    });
    _filterConstants();
  }

  bool _isConstantFavorited(PhysicalConstant constant) {
    return favoriteConstantIds.contains(constant.id);
  }

  Future<void> _toggleConstantFavorite(PhysicalConstant constant) async {
    if (_isConstantFavorited(constant)) {
      try {
        final favorites = await FavoritesService.instance.getAllFavorites();
        final match = favorites.where(
          (f) => f.type == 'constant' && f.label == constant.symbol,
        );
        for (final fav in match) {
          await FavoritesService.instance.removeFavorite(fav.id);
        }
        if (mounted) {
          setState(() {
            favoriteConstantIds.remove(constant.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Removed ${constant.symbol} from favorites',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF293548),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error removing favorite: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF293548),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      try {
        await FavoritesService.instance.addFavorite(
          type: 'constant',
          label: constant.symbol,
          value: constant.value,
          unit: constant.unit,
          category: constant.category,
        );
        if (mounted) {
          setState(() {
            favoriteConstantIds.add(constant.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${constant.symbol} to favorites',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF293548),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error adding favorite: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF293548),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _copyConstantValue(PhysicalConstant constant) {
    Clipboard.setData(ClipboardData(text: constant.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied: ${constant.value}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF293548),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _insertConstantIntoCalculator(PhysicalConstant constant) {
    Navigator.pop(context, constant.symbol);
  }

  String _buildEmptyMessage() {
    if (searchQuery.isNotEmpty && selectedCategory != null) {
      return 'No matching constants in $selectedCategory';
    } else if (searchQuery.isNotEmpty) {
      return 'No matching constants';
    } else if (selectedCategory != null) {
      return 'No constants in $selectedCategory';
    }
    return 'No constants found';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physical Constants'),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                  ),
                  hintText: 'Search constants...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF4C6EF5),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(
                        'All',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      selected: selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) _setCategory(null);
                      },
                      backgroundColor: const Color(0xFF1E293B),
                      selectedColor: const Color(0xFF4C6EF5),
                      checkmarkColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF334155)),
                      labelStyle: TextStyle(
                        color: selectedCategory == null
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          _setCategory(selected ? cat : null);
                        },
                        backgroundColor: const Color(0xFF1E293B),
                        selectedColor: const Color(0xFF4C6EF5),
                        checkmarkColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4C6EF5),
                      ),
                    )
                  : filteredConstants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.science_rounded,
                                size: 48,
                                color: Color(0xFF334155),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _buildEmptyMessage(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredConstants.length,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemBuilder: (context, index) {
                            final constant = filteredConstants[index];
                            final isFavorited =
                                _isConstantFavorited(constant);
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                constant.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4C6EF5)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                constant.category,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF4C6EF5),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${constant.symbol} = ${constant.value} ${constant.unit}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                            fontFamily: 'Roboto Mono',
                                          ),
                                        ),
                                        if (constant.uncertainty != null &&
                                            constant.uncertainty!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'σ = ${constant.uncertainty}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(
                                      isFavorited
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                    ),
                                    onPressed: () =>
                                        _toggleConstantFavorite(constant),
                                    color: isFavorited
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF64748B),
                                    tooltip: isFavorited
                                        ? 'Remove from favorites'
                                        : 'Add to favorites',
                                    iconSize: 22,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.content_copy_rounded),
                                    onPressed: () =>
                                        _copyConstantValue(constant),
                                    color: const Color(0xFF94A3B8),
                                    tooltip: 'Copy value',
                                    iconSize: 22,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded),
                                    onPressed: () =>
                                        _insertConstantIntoCalculator(
                                            constant),
                                    color: const Color(0xFF4C6EF5),
                                    tooltip: 'Insert into calculator',
                                    iconSize: 22,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}