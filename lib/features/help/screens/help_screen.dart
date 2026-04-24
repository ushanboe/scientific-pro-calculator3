import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scientific_pro_calculator/services/help_articles_service.dart';

// Local category model for the tree view
class _HelpCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<HelpArticle> articles;

  const _HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.articles,
  });
}

class HelpScreen extends StatefulWidget {
  final String? anchorId;

  const HelpScreen({super.key, this.anchorId});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String? _selectedArticleId;
  List<HelpArticle> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  // Track which categories are expanded in the tree view
  final Set<String> _expandedCategories = {'getting_started'};

  // All help categories and articles (hardcoded for reliability)
  late final List<_HelpCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _buildHelpContent();
    _searchController.addListener(_onSearchChanged);

    // Handle deep-link anchor
    if (widget.anchorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAnchor(widget.anchorId!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      if (query == _searchQuery) return;
      setState(() {
        _searchQuery = query;
        _selectedArticleId = null;
      });
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await HelpArticlesService.instance.search(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      // Fallback: search in local data
      if (mounted) {
        final lowerQuery = query.toLowerCase();
        final localResults = <HelpArticle>[];
        for (final category in _categories) {
          for (final article in category.articles) {
            if (article.title.toLowerCase().contains(lowerQuery) ||
                article.content.toLowerCase().contains(lowerQuery) ||
                article.tags.any((t) => t.toLowerCase().contains(lowerQuery))) {
              localResults.add(article);
            }
          }
        }
        setState(() {
          _searchResults = localResults;
          _isSearching = false;
        });
      }
    }
  }

  void _navigateToAnchor(String anchorId) async {
    try {
      final result =
          await HelpArticlesService.instance.getArticleByAnchor(anchorId);
      if (result != null && mounted) {
        setState(() {
          _selectedArticleId = result.article.id;
          _searchController.clear();
          _searchQuery = '';
          _searchResults = [];
          // Expand the category containing this article
          for (final cat in _categories) {
            if (cat.articles.any((a) => a.id == result.article.id)) {
              _expandedCategories.add(cat.id);
            }
          }
        });
        return;
      }
    } catch (_) {}

    // Fallback: search in local data
    for (final category in _categories) {
      for (final article in category.articles) {
        if (article.id == anchorId || article.anchorId == anchorId) {
          if (mounted) {
            setState(() {
              _selectedArticleId = article.id;
              _expandedCategories.add(category.id);
            });
          }
          return;
        }
      }
    }
  }

  void _selectArticle(HelpArticle article) {
    setState(() {
      _selectedArticleId = article.id;
    });
  }

  void _clearArticle() {
    setState(() {
      _selectedArticleId = null;
    });
  }

  HelpArticle? _findArticleById(String id) {
    for (final category in _categories) {
      for (final article in category.articles) {
        if (article.id == id) return article;
      }
    }
    return null;
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
      _selectedArticleId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If an article is selected, show article detail view
    if (_selectedArticleId != null) {
      final article = _findArticleById(_selectedArticleId!);
      if (article != null) {
        return _buildArticleDetailView(article, theme, colorScheme);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: _searchQuery.isNotEmpty
            ? null
            : const Text('Help & Documentation'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: _searchQuery.isNotEmpty
          ? _buildSearchResults(theme, colorScheme)
          : _buildCategoryTree(theme, colorScheme),
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colorScheme) {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_searchQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final article = _searchResults[index];
        return _buildArticleListTile(article, theme, colorScheme,
            showCategory: true);
      },
    );
  }

  Widget _buildCategoryTree(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isExpanded = _expandedCategories.contains(category.id);
        return _buildCategorySection(category, isExpanded, theme, colorScheme);
      },
    );
  }

  Widget _buildCategorySection(
    _HelpCategory category,
    bool isExpanded,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleCategory(category.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${category.articles.length} article${category.articles.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: category.articles
                .map((article) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildArticleListTile(
                          article, theme, colorScheme,
                          showCategory: false),
                    ))
                .toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildArticleListTile(
    HelpArticle article,
    ThemeData theme,
    ColorScheme colorScheme, {
    required bool showCategory,
  }) {
    String? categoryName;
    if (showCategory) {
      for (final cat in _categories) {
        if (cat.articles.any((a) => a.id == article.id)) {
          categoryName = cat.title;
          break;
        }
      }
    }

    // Use first 120 chars of content as summary
    final summary = article.content.length > 120
        ? '${article.content.substring(0, 120)}...'
        : article.content;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        Icons.article_rounded,
        size: 20,
        color: colorScheme.primary.withValues(alpha: 0.7),
      ),
      title: Text(
        article.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showCategory && categoryName != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                categoryName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () => _selectArticle(article),
    );
  }

  Widget _buildArticleDetailView(
    HelpArticle article,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _clearArticle,
        ),
        title: Text(
          article.title,
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy article',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: '${article.title}\n\n${article.content}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags
            if (article.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: article.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Main content
            Text(
              article.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
            // Sections
            if (article.sections.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...article.sections.map((section) => _buildSection(
                  section, theme, colorScheme)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    HelpSection section,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 3,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                section.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Help Content ─────────────────────────────────────────────────────────

  List<_HelpCategory> _buildHelpContent() {
    return [
      _HelpCategory(
        id: 'getting_started',
        title: 'Getting Started',
        icon: Icons.rocket_launch_rounded,
        articles: [
          HelpArticle(
            id: 'overview',
            title: 'App Overview',
            content:
                'Scientific Pro Calculator is a powerful calculator with support for complex numbers, graphing, symbolic math, statistics, matrix operations, and unit conversions.',
            anchorId: 'overview',
            category: 'Getting Started',
            tags: ['intro', 'overview'],
            sections: [
              HelpSection(
                title: 'Navigation',
                content:
                    'Use the bottom navigation bar to switch between Calculator, Graph, Equations, Matrices, Statistics, Units, and Help screens.',
                anchorId: 'navigation',
              ),
            ],
          ),
          HelpArticle(
            id: 'calculator_modes',
            title: 'Calculator Modes',
            content:
                'The calculator supports two input modes: Infix (standard algebraic notation) and RPN (Reverse Polish Notation). Switch between modes in Settings.',
            anchorId: 'calculator_modes',
            category: 'Getting Started',
            tags: ['infix', 'rpn', 'mode'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'calculator',
        title: 'Calculator',
        icon: Icons.calculate_rounded,
        articles: [
          HelpArticle(
            id: 'basic_operations',
            title: 'Basic Operations',
            content:
                'Tap number and operator buttons to build an expression. Press = to evaluate. The result appears in the display area.',
            anchorId: 'basic_operations',
            category: 'Calculator',
            tags: ['arithmetic', 'basic', 'operations'],
            sections: [
              HelpSection(
                title: 'Operators',
                content:
                    'Use +, -, ×, ÷ for basic arithmetic. Use ^ for powers. Use % for percentage.',
                anchorId: 'operators',
              ),
            ],
          ),
          HelpArticle(
            id: 'complex_numbers',
            title: 'Complex Numbers',
            content:
                'Enter complex numbers using the i button. Results show both rectangular (a+bi) and polar (r∠θ) forms.',
            anchorId: 'complex_numbers',
            category: 'Calculator',
            tags: ['complex', 'imaginary', 'polar'],
            sections: [],
          ),
          HelpArticle(
            id: 'rpn_mode',
            title: 'RPN Mode',
            content:
                'In RPN mode, enter operands and press Enter to push them onto the stack. Then press an operator to apply it to the top stack values.',
            anchorId: 'rpn_mode',
            category: 'Calculator',
            tags: ['rpn', 'stack', 'postfix'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'graphing',
        title: 'Graphing',
        icon: Icons.show_chart_rounded,
        articles: [
          HelpArticle(
            id: 'graphing_overview',
            title: 'Graphing Overview',
            content:
                'Plot 2D functions and 3D surfaces with zoom, pan, trace, integral area shading, and limit visualization.',
            anchorId: 'graphing_overview',
            category: 'Graphing',
            tags: ['graph', 'plot', '2d', '3d'],
            sections: [
              HelpSection(
                title: 'Adding Functions',
                content:
                    'Tap the + button to add a function. Enter an expression in terms of x (for 2D) or x and y (for 3D).',
                anchorId: 'adding_functions',
              ),
              HelpSection(
                title: 'Zoom and Pan',
                content:
                    'Pinch to zoom and drag to pan the graph viewport. Use the axis range inputs to set precise bounds.',
                anchorId: 'zoom_pan',
              ),
            ],
          ),
        ],
      ),
      _HelpCategory(
        id: 'symbolic',
        title: 'Symbolic Math',
        icon: Icons.functions_rounded,
        articles: [
          HelpArticle(
            id: 'derivatives',
            title: 'Derivatives',
            content:
                'Enter an expression and select the variable. Choose the differentiation order (1st, 2nd, etc.) and tap Compute.',
            anchorId: 'derivatives',
            category: 'Symbolic Math',
            tags: ['derivative', 'calculus', 'differentiation'],
            sections: [],
          ),
          HelpArticle(
            id: 'integrals',
            title: 'Integrals',
            content:
                'Toggle between indefinite and definite integration. For definite integrals, enter lower and upper bounds.',
            anchorId: 'integrals',
            category: 'Symbolic Math',
            tags: ['integral', 'calculus', 'integration'],
            sections: [],
          ),
          HelpArticle(
            id: 'taylor_series',
            title: 'Taylor Series',
            content:
                'Enter the expansion point and series order to generate the Taylor polynomial approximation.',
            anchorId: 'taylor_series',
            category: 'Symbolic Math',
            tags: ['taylor', 'series', 'approximation'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'statistics',
        title: 'Statistics',
        icon: Icons.bar_chart_rounded,
        articles: [
          HelpArticle(
            id: 'descriptive_stats',
            title: 'Descriptive Statistics',
            content:
                'Enter comma-separated data in the Descriptive tab. Tap Compute to calculate mean, median, mode, standard deviation, variance, quartiles, and more.',
            anchorId: 'descriptive_stats',
            category: 'Statistics',
            tags: ['mean', 'median', 'std dev', 'variance'],
            sections: [],
          ),
          HelpArticle(
            id: 'distributions',
            title: 'Probability Distributions',
            content:
                'Select a distribution (Normal, Binomial, Poisson, etc.), enter parameters and an x value, then tap Evaluate to get PDF and CDF values.',
            anchorId: 'distributions',
            category: 'Statistics',
            tags: ['normal', 'binomial', 'pdf', 'cdf'],
            sections: [],
          ),
          HelpArticle(
            id: 'regression',
            title: 'Regression Analysis',
            content:
                'Enter X and Y data, select a regression type (Linear, Polynomial, Exponential, etc.), and tap Fit to get the regression equation and R² value.',
            anchorId: 'regression',
            category: 'Statistics',
            tags: ['regression', 'linear', 'polynomial', 'r-squared'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'matrices',
        title: 'Matrices & Vectors',
        icon: Icons.grid_on_rounded,
        articles: [
          HelpArticle(
            id: 'matrix_operations',
            title: 'Matrix Operations',
            content:
                'Enter matrix values in the grid. Select an operation (add, subtract, multiply, transpose, invert, determinant, etc.) and tap Compute.',
            anchorId: 'matrix_operations',
            category: 'Matrices',
            tags: ['matrix', 'determinant', 'inverse', 'transpose'],
            sections: [],
          ),
          HelpArticle(
            id: 'decompositions',
            title: 'Matrix Decompositions',
            content:
                'Choose LU, QR, or SVD decomposition from the decomposition section. Factor matrices are displayed in the result area.',
            anchorId: 'decompositions',
            category: 'Matrices',
            tags: ['lu', 'qr', 'svd', 'decomposition'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'units',
        title: 'Unit Converter',
        icon: Icons.swap_horiz_rounded,
        articles: [
          HelpArticle(
            id: 'unit_conversion',
            title: 'Unit Conversion',
            content:
                'Select a category (Length, Mass, Temperature, etc.), choose From and To units, enter a value, and see the result instantly.',
            anchorId: 'unit_conversion',
            category: 'Units',
            tags: ['convert', 'units', 'length', 'mass', 'temperature'],
            sections: [],
          ),
        ],
      ),
      _HelpCategory(
        id: 'settings',
        title: 'Settings',
        icon: Icons.settings_rounded,
        articles: [
          HelpArticle(
            id: 'display_settings',
            title: 'Display Settings',
            content:
                'Configure decimal places, display format (standard, scientific, engineering), digit separator, and angle mode (degrees/radians/gradians).',
            anchorId: 'display_settings',
            category: 'Settings',
            tags: ['decimal', 'scientific', 'engineering', 'angle mode'],
            sections: [],
          ),
          HelpArticle(
            id: 'theme_settings',
            title: 'Theme & Appearance',
            content:
                'Switch between dark and light themes. Choose from multiple color schemes to personalize the app.',
            anchorId: 'theme_settings',
            category: 'Settings',
            tags: ['theme', 'dark mode', 'color', 'appearance'],
            sections: [],
          ),
        ],
      ),
    ];
  }
}
