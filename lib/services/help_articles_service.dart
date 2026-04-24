// Step 1: Inventory
// This file DEFINES: HelpArticlesService class with:
//   - Singleton instance
//   - List<HelpArticle> _articles (in-memory cache)
//   - HelpArticle model (nested or separate class)
//   - HelpSection model
//   - loadArticles(): loads from JSON asset lib/assets/data/help_articles.json
//   - search(String query): filters articles by title/content LIKE
//   - getArticleByAnchor(String anchorId): deep-link lookup
//   - getAllArticles(): returns all articles
//   - getArticlesByCategory(String category): filter by category
//
// Step 2: Connections
// - Used by: help_screen.dart (search, getArticleByAnchor, getAllArticles)
// - Wiring: HelpScreen → HelpArticlesService.search() and HelpArticlesService.getArticleByAnchor()
// - No imports from other project files needed — standalone service
// - Loads JSON from assets/data/help_articles.json via rootBundle
//
// Step 3: User Journey Trace
// App starts → HelpScreen opens → loadArticles() called once → cache populated
// User types in search → search(query) called → filters _articles by title/content
// Feature tooltip deep-link → getArticleByAnchor(anchorId) → returns matching article
// Tree-view navigation → getAllArticles() or getArticlesByCategory() → display list
//
// Step 4: Layout Sanity
// Pure service — no widgets
// JSON asset path: lib/assets/data/help_articles.json (as declared in file manifest)
// HelpArticle model needs: id, title, content, anchorId, category, sections
// HelpSection model needs: title, content, anchorId
// search() does case-insensitive contains on title and content
// getArticleByAnchor() checks article anchorId AND section anchorIds for deep linking

import 'dart:convert';
import 'package:flutter/services.dart';

class HelpSection {
  final String title;
  final String content;
  final String? anchorId;

  const HelpSection({
    required this.title,
    required this.content,
    this.anchorId,
  });

  factory HelpSection.fromJson(Map<String, dynamic> json) {
    return HelpSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      anchorId: json['anchorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (anchorId != null) 'anchorId': anchorId,
    };
  }

  @override
  String toString() => 'HelpSection(title: $title, anchorId: $anchorId)';
}

class HelpArticle {
  final String id;
  final String title;
  final String content;
  final String? anchorId;
  final String category;
  final List<HelpSection> sections;
  final List<String> tags;

  const HelpArticle({
    required this.id,
    required this.title,
    required this.content,
    this.anchorId,
    required this.category,
    required this.sections,
    required this.tags,
  });

  factory HelpArticle.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final List<HelpSection> sections;
    if (rawSections is List) {
      sections = rawSections
          .whereType<Map<String, dynamic>>()
          .map((s) => HelpSection.fromJson(s))
          .toList();
    } else {
      sections = const [];
    }

    final rawTags = json['tags'];
    final List<String> tags;
    if (rawTags is List) {
      tags = rawTags.map((t) => t.toString()).toList();
    } else {
      tags = const [];
    }

    return HelpArticle(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      anchorId: json['anchorId'] as String?,
      category: json['category'] as String? ?? 'General',
      sections: sections,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      if (anchorId != null) 'anchorId': anchorId,
      'category': category,
      'sections': sections.map((s) => s.toJson()).toList(),
      'tags': tags,
    };
  }

  /// Returns all text content (title + content + all section titles/content) for searching.
  String get fullText {
    final buf = StringBuffer();
    buf.write(title);
    buf.write(' ');
    buf.write(content);
    for (final section in sections) {
      buf.write(' ');
      buf.write(section.title);
      buf.write(' ');
      buf.write(section.content);
    }
    buf.write(' ');
    buf.write(tags.join(' '));
    return buf.toString();
  }

  @override
  String toString() =>
      'HelpArticle(id: $id, title: $title, category: $category, anchorId: $anchorId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HelpArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Result of a deep-link anchor lookup — may point to an article or a specific section.
class HelpAnchorResult {
  final HelpArticle article;
  final HelpSection? section;

  const HelpAnchorResult({
    required this.article,
    this.section,
  });
}

class HelpArticlesService {
  static final HelpArticlesService instance = HelpArticlesService._();
  HelpArticlesService._();

  static const String _assetPath = 'lib/assets/data/help_articles.json';

  List<HelpArticle> _articles = [];
  bool _loaded = false;

  /// Load articles from the bundled JSON asset. Safe to call multiple times —
  /// subsequent calls return immediately if already loaded.
  Future<void> loadArticles() async {
    if (_loaded) return;
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _articles = decoded
            .whereType<Map<String, dynamic>>()
            .map((json) => HelpArticle.fromJson(json))
            .toList();
      } else if (decoded is Map<String, dynamic> &&
          decoded.containsKey('articles')) {
        final rawList = decoded['articles'];
        if (rawList is List) {
          _articles = rawList
              .whereType<Map<String, dynamic>>()
              .map((json) => HelpArticle.fromJson(json))
              .toList();
        }
      }
      _loaded = true;
      print('HELP_ARTICLES_SERVICE loaded ${_articles.length} articles');
    } catch (e) {
      print('HELP_ARTICLES_SERVICE load error: $e — using built-in fallback');
      _articles = _builtinArticles();
      _loaded = true;
    }
  }

  /// Returns all loaded articles. Calls loadArticles() if not yet loaded.
  Future<List<HelpArticle>> getAllArticles() async {
    await loadArticles();
    return List<HelpArticle>.unmodifiable(_articles);
  }

  /// Returns articles filtered by category (case-insensitive).
  Future<List<HelpArticle>> getArticlesByCategory(String category) async {
    await loadArticles();
    final lower = category.toLowerCase();
    return _articles
        .where((a) => a.category.toLowerCase() == lower)
        .toList();
  }

  /// Returns all unique categories present in the loaded articles.
  Future<List<String>> getCategories() async {
    await loadArticles();
    final categories = <String>{};
    for (final article in _articles) {
      categories.add(article.category);
    }
    final sorted = categories.toList()..sort();
    return sorted;
  }

  /// Search articles by title, content, section titles, section content, and tags.
  /// Returns articles where any of those fields contain [query] (case-insensitive).
  Future<List<HelpArticle>> search(String query) async {
    await loadArticles();
    if (query.trim().isEmpty) {
      return List<HelpArticle>.unmodifiable(_articles);
    }
    final lower = query.toLowerCase().trim();
    return _articles
        .where((article) => article.fullText.toLowerCase().contains(lower))
        .toList();
  }

  /// Synchronous search for use in real-time filtering after initial load.
  /// Returns empty list if articles not yet loaded.
  List<HelpArticle> searchSync(String query) {
    if (!_loaded) return const [];
    if (query.trim().isEmpty) return List<HelpArticle>.unmodifiable(_articles);
    final lower = query.toLowerCase().trim();
    return _articles
        .where((article) => article.fullText.toLowerCase().contains(lower))
        .toList();
  }

  /// Find an article (or section within an article) by its deep-link anchor ID.
  /// Returns null if no match found.
  Future<HelpAnchorResult?> getArticleByAnchor(String anchorId) async {
    await loadArticles();
    if (anchorId.trim().isEmpty) return null;

    // First check top-level article anchorIds
    for (final article in _articles) {
      if (article.anchorId == anchorId) {
        return HelpAnchorResult(article: article);
      }
    }

    // Then check section anchorIds within each article
    for (final article in _articles) {
      for (final section in article.sections) {
        if (section.anchorId == anchorId) {
          return HelpAnchorResult(article: article, section: section);
        }
      }
    }

    // Fallback: search by article id
    for (final article in _articles) {
      if (article.id == anchorId) {
        return HelpAnchorResult(article: article);
      }
    }

    print('HELP_ARTICLES_SERVICE anchor not found: $anchorId');
    return null;
  }

  /// Get a single article by its ID.
  Future<HelpArticle?> getArticleById(String id) async {
    await loadArticles();
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Reset the loaded state (useful for testing or forced reload).
  void reset() {
    _articles = [];
    _loaded = false;
  }

  /// Built-in fallback articles used when the JSON asset fails to load.
  List<HelpArticle> _builtinArticles() {
    return [
      HelpArticle(
        id: 'getting_started',
        title: 'Getting Started',
        content:
            'Welcome to Scientific Pro Calculator. This guide covers the core features of the app.',
        anchorId: 'getting_started',
        category: 'Overview',
        tags: ['intro', 'overview', 'start'],
        sections: [
          HelpSection(
            title: 'Calculator Modes',
            content:
                'The app supports two input modes: Infix (standard algebraic notation) and RPN (Reverse Polish Notation). Switch between modes in Settings.',
            anchorId: 'calculator_modes',
          ),
          HelpSection(
            title: 'High-Precision Arithmetic',
            content:
                'All calculations use up to 100-digit precision via the decimal package. Set the number of displayed decimal places in Settings.',
            anchorId: 'high_precision',
          ),
        ],
      ),
      HelpArticle(
        id: 'calculator',
        title: 'Calculator',
        content:
            'The main calculator screen supports arithmetic, trigonometry, logarithms, complex numbers, and more.',
        anchorId: 'calculator',
        category: 'Features',
        tags: ['calculate', 'arithmetic', 'infix', 'rpn', 'complex'],
        sections: [
          HelpSection(
            title: 'Basic Operations',
            content:
                'Tap number and operator buttons to build an expression. Press = to evaluate. The result appears in the display area.',
            anchorId: 'basic_operations',
          ),
          HelpSection(
            title: 'RPN Mode',
            content:
                'In RPN mode, enter operands and press Enter to push them onto the stack. Then press an operator to apply it to the top stack values.',
            anchorId: 'rpn_mode',
          ),
          HelpSection(
            title: 'Complex Numbers',
            content:
                'Enter complex numbers using the i button. Results show both rectangular (a+bi) and polar (r∠θ) forms.',
            anchorId: 'complex_numbers',
          ),
          HelpSection(
            title: 'Undo and Redo',
            content:
                'Use the undo (↩) and redo (↪) buttons to step through your expression history.',
            anchorId: 'undo_redo',
          ),
        ],
      ),
      HelpArticle(
        id: 'graphs',
        title: 'Graphing',
        content:
            'Plot 2D functions and 3D surfaces with zoom, pan, trace, integral area shading, and limit visualization.',
        anchorId: 'graphs',
        category: 'Features',
        tags: ['graph', 'plot', '2d', '3d', 'function', 'integral', 'limit'],
        sections: [
          HelpSection(
            title: 'Adding Functions',
            content:
                'Tap the + button to add a function. Enter an expression in terms of x (for 2D) or x and y (for 3D). Each function is drawn in a distinct color.',
            anchorId: 'adding_functions',
          ),
          HelpSection(
            title: 'Zoom and Pan',
            content:
                'Pinch to zoom and drag to pan the graph viewport. Use the axis range inputs to set precise bounds.',
            anchorId: 'zoom_pan',
          ),
          HelpSection(
            title: 'Integral Area',
            content:
                'Enable the integral toggle and set lower/upper bounds to shade the area under a curve and display the computed integral value.',
            anchorId: 'integral_area',
          ),
          HelpSection(
            title: 'Limit Visualization',
            content:
                'Enable the limit toggle and set a target x value to animate the approach and display the computed limit.',
            anchorId: 'limit_visualization',
          ),
        ],
      ),
      HelpArticle(
        id: 'symbolic',
        title: 'Symbolic Math',
        content:
            'Compute symbolic derivatives, integrals, limits, Taylor series, and simplify algebraic expressions.',
        anchorId: 'symbolic',
        category: 'Features',
        tags: [
          'symbolic',
          'derivative',
          'integral',
          'limit',
          'taylor',
          'simplify',
          'calculus'
        ],
        sections: [
          HelpSection(
            title: 'Derivatives',
            content:
                'Enter an expression and select the variable. Choose the differentiation order (1st, 2nd, etc.) and tap Compute.',
            anchorId: 'derivatives',
          ),
          HelpSection(
            title: 'Integrals',
            content:
                'Toggle between indefinite and definite integration. For definite integrals, enter lower and upper bounds.',
            anchorId: 'integrals',
          ),
          HelpSection(
            title: 'Taylor Series',
            content:
                'Enter the expansion point and series order to generate the Taylor polynomial approximation.',
            anchorId: 'taylor_series',
          ),
        ],
      ),
      HelpArticle(
        id: 'equation_solver',
        title: 'Equation Solver',
        content:
            'Solve single-variable and multi-variable algebraic equations symbolically and numerically.',
        anchorId: 'equation_solver',
        category: 'Features',
        tags: ['equation', 'solve', 'roots', 'system', 'algebraic'],
        sections: [
          HelpSection(
            title: 'Single Variable',
            content:
                'Enter an equation with one unknown (e.g., x^2 - 4 = 0). Tap Solve to get all roots including complex ones.',
            anchorId: 'single_variable',
          ),
          HelpSection(
            title: 'System of Equations',
            content:
                'Switch to System mode to enter multiple equations. The solver finds the intersection of all constraints.',
            anchorId: 'system_equations',
          ),
        ],
      ),
      HelpArticle(
        id: 'matrices',
        title: 'Matrix & Vector Operations',
        content:
            'Create matrices and vectors, perform linear algebra operations, decompositions, and eigenvalue analysis.',
        anchorId: 'matrices',
        category: 'Features',
        tags: [
          'matrix',
          'vector',
          'eigenvalue',
          'determinant',
          'decomposition',
          'lu',
          'qr',
          'svd'
        ],
        sections: [
          HelpSection(
            title: 'Entering Matrices',
            content:
                'Tap cells to enter values. Use the dimension controls to set the number of rows and columns (up to 8×8).',
            anchorId: 'entering_matrices',
          ),
          HelpSection(
            title: 'Operations',
            content:
                'Select two matrices and choose an operation: add, subtract, multiply, or compute the Hadamard product.',
            anchorId: 'matrix_operations',
          ),
          HelpSection(
            title: 'Decompositions',
            content:
                'Choose LU, QR, or SVD decomposition from the decomposition menu. Factor matrices are displayed separately.',
            anchorId: 'matrix_decompositions',
          ),
          HelpSection(
            title: 'Eigenvalues',
            content:
                'Tap the Eigenvalues button on a square matrix to compute all eigenvalues and their corresponding eigenvectors.',
            anchorId: 'eigenvalues',
          ),
        ],
      ),
      HelpArticle(
        id: 'units',
        title: 'Unit Conversion',
        content:
            'Convert between 250+ units across length, mass, temperature, time, energy, and more with SI prefix support.',
        anchorId: 'units',
        category: 'Features',
        tags: [
          'unit',
          'conversion',
          'convert',
          'length',
          'mass',
          'temperature',
          'SI',
          'prefix'
        ],
        sections: [
          HelpSection(
            title: 'Converting Units',
            content:
                'Select a category, choose the source and target units, then enter a value. The conversion updates in real time.',
            anchorId: 'converting_units',
          ),
          HelpSection(
            title: 'SI Prefixes',
            content:
                'All SI units support prefixes (kilo, mega, giga, milli, micro, etc.). Select the prefix from the unit picker.',
            anchorId: 'si_prefixes',
          ),
        ],
      ),
      HelpArticle(
        id: 'statistics',
        title: 'Statistics',
        content:
            'Compute descriptive statistics, evaluate probability distributions, run hypothesis tests, and fit regression models.',
        anchorId: 'statistics',
        category: 'Features',
        tags: [
          'stats',
          'statistics',
          'mean',
          'median',
          'regression',
          'hypothesis',
          'distribution',
          'probability'
        ],
        sections: [
          HelpSection(
            title: 'Descriptive Statistics',
            content:
                'Enter your data in the table. The app computes mean, median, mode, standard deviation, variance, and quartiles automatically.',
            anchorId: 'descriptive_stats',
          ),
          HelpSection(
            title: 'Probability Distributions',
            content:
                'Select a distribution (Normal, Binomial, Poisson, etc.) and enter its parameters to evaluate the PDF and CDF at any point.',
            anchorId: 'distributions',
          ),
          HelpSection(
            title: 'Hypothesis Testing',
            content:
                'Choose a test (t-test, z-test, chi-square) and enter your data and confidence level. The app displays the test statistic, p-value, and conclusion.',
            anchorId: 'hypothesis_testing',
          ),
          HelpSection(
            title: 'Regression',
            content:
                'Enter paired x/y data and select a regression type (linear, polynomial, exponential). The app fits the curve, computes R², and displays the equation.',
            anchorId: 'regression',
          ),
        ],
      ),
      HelpArticle(
        id: 'history',
        title: 'Calculation History',
        content:
            'All calculations are automatically saved. Browse, search, recall, and export your history.',
        anchorId: 'history',
        category: 'Features',
        tags: ['history', 'recall', 'export', 'search', 'clear'],
        sections: [
          HelpSection(
            title: 'Recalling Calculations',
            content:
                'Tap any history entry to load its expression back into the calculator.',
            anchorId: 'recalling_calculations',
          ),
          HelpSection(
            title: 'Exporting History',
            content:
                'Tap the export button to save your history as JSON, CSV, or PDF. Share the file via the Android share sheet.',
            anchorId: 'exporting_history',
          ),
        ],
      ),
      HelpArticle(
        id: 'constants',
        title: 'Physical Constants',
        content:
            'Browse and search 90+ CODATA physical constants. Insert them directly into calculations.',
        anchorId: 'constants',
        category: 'Features',
        tags: [
          'constant',
          'physics',
          'planck',
          'speed of light',
          'boltzmann',
          'CODATA'
        ],
        sections: [
          HelpSection(
            title: 'Searching Constants',
            content:
                'Type in the search bar to filter by name, symbol, or category. Tap a constant to see its full value and uncertainty.',
            anchorId: 'searching_constants',
          ),
          HelpSection(
            title: 'Inserting Constants',
            content:
                'Tap the insert icon next to a constant to add its symbol to the current calculator expression.',
            anchorId: 'inserting_constants',
          ),
        ],
      ),
      HelpArticle(
        id: 'favorites',
        title: 'Favorites',
        content:
            'Star frequently used functions, constants, and unit conversions for quick access from the calculator toolbar.',
        anchorId: 'favorites',
        category: 'Features',
        tags: ['favorites', 'star', 'toolbar', 'quick access', 'reorder'],
        sections: [
          HelpSection(
            title: 'Adding Favorites',
            content:
                'Tap the star icon next to any function, constant, or unit conversion to add it to your favorites.',
            anchorId: 'adding_favorites',
          ),
          HelpSection(
            title: 'Reordering Favorites',
            content:
                'In the Favorites screen, drag items to reorder them. The order is reflected in the calculator toolbar.',
            anchorId: 'reordering_favorites',
          ),
        ],
      ),
      HelpArticle(
        id: 'settings',
        title: 'Settings',
        content:
            'Customize display format, precision, angle mode, RPN mode, haptic feedback, theme, and more.',
        anchorId: 'settings',
        category: 'Configuration',
        tags: [
          'settings',
          'theme',
          'dark mode',
          'light mode',
          'precision',
          'angle',
          'degrees',
          'radians',
          'haptic',
          'rpn'
        ],
        sections: [
          HelpSection(
            title: 'Display Format',
            content:
                'Choose between Fixed, Scientific, Engineering, and DMS (degrees/minutes/seconds) display formats.',
            anchorId: 'display_format',
          ),
          HelpSection(
            title: 'Angle Mode',
            content:
                'Set the angle unit to Degrees, Radians, or Gradians. This affects all trigonometric functions.',
            anchorId: 'angle_mode',
          ),
          HelpSection(
            title: 'Precision',
            content:
                'Set the number of decimal places (0–15) and the significand digit count (1–100) for high-precision mode.',
            anchorId: 'precision_settings',
          ),
          HelpSection(
            title: 'Theme',
            content:
                'Choose Light, Dark, or System theme. The System option follows your device\'s appearance setting.',
            anchorId: 'theme_settings',
          ),
        ],
      ),
    ];
  }
}