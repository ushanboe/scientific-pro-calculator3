import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:scientific_pro_calculator/models/calculation_history.dart';
import 'package:scientific_pro_calculator/models/saved_matrix.dart';
import 'package:scientific_pro_calculator/models/saved_graph.dart';
import 'package:scientific_pro_calculator/models/stat_dataset.dart';

class HistoryService {
  static final HistoryService instance = HistoryService._internal();
  HistoryService._internal();

  static Database? _database;
  static const int _dbVersion = 1;
  static const String _dbName = 'scientific_pro_calculator.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS calculation_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        result_type TEXT NOT NULL DEFAULT 'real',
        is_complex INTEGER NOT NULL DEFAULT 0,
        magnitude TEXT,
        phase TEXT,
        polar_form TEXT,
        display_format TEXT NOT NULL DEFAULT 'fixed',
        angle_mode TEXT NOT NULL DEFAULT 'degrees',
        input_mode TEXT NOT NULL DEFAULT 'infix',
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        label TEXT NOT NULL,
        value TEXT NOT NULL,
        unit TEXT,
        category TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_matrices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        rows INTEGER NOT NULL,
        cols INTEGER NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_graphs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mode TEXT NOT NULL DEFAULT '2d',
        functions TEXT NOT NULL DEFAULT '[]',
        x_min REAL NOT NULL DEFAULT -10.0,
        x_max REAL NOT NULL DEFAULT 10.0,
        y_min REAL NOT NULL DEFAULT -10.0,
        y_max REAL NOT NULL DEFAULT 10.0,
        integral_lower REAL,
        integral_upper REAL,
        show_integral_area INTEGER NOT NULL DEFAULT 0,
        limit_target_x REAL,
        show_limit_visualization INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stat_datasets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        columns TEXT NOT NULL DEFAULT '[]',
        rows TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS physical_constants (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        value TEXT NOT NULL,
        unit TEXT NOT NULL,
        uncertainty TEXT,
        category TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_timestamp ON calculation_history(timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_expression ON calculation_history(expression)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favorites_sort ON favorites(sort_order ASC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_constants_category ON physical_constants(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_constants_symbol ON physical_constants(symbol)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS calculation_history');
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('DROP TABLE IF EXISTS saved_matrices');
    await db.execute('DROP TABLE IF EXISTS saved_graphs');
    await db.execute('DROP TABLE IF EXISTS stat_datasets');
    await db.execute('DROP TABLE IF EXISTS physical_constants');
    await _onCreate(db, newVersion);
  }

  // ─── Calculation History ────────────────────────────────────────────────────

  Future<CalculationHistory> addCalculation(CalculationHistory entry) async {
    final db = await database;
    final map = entry.toMap();
    final id = await db.insert(
      'calculation_history',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return entry.copyWith(id: id);
  }

  Future<List<CalculationHistory>> getAllHistory() async {
    final db = await database;
    final rows = await db.query(
      'calculation_history',
      orderBy: 'timestamp DESC',
    );
    return rows.map((row) => CalculationHistory.fromMap(row)).toList();
  }

  Future<List<CalculationHistory>> searchHistory(String query) async {
    if (query.trim().isEmpty) return getAllHistory();
    final db = await database;
    final pattern = '%${query.trim()}%';
    final rows = await db.query(
      'calculation_history',
      where: 'expression LIKE ? OR result LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'timestamp DESC',
    );
    return rows.map((row) => CalculationHistory.fromMap(row)).toList();
  }

  Future<int> deleteCalculation(int id) async {
    final db = await database;
    return await db.delete(
      'calculation_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Alias for deleteCalculation — used by history_screen.dart
  Future<int> deleteHistory(int id) => deleteCalculation(id);

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('calculation_history');
  }

  Future<int> getHistoryCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM calculation_history',
    );
    return result.first['count'] as int? ?? 0;
  }

  // ─── Saved Matrices ─────────────────────────────────────────────────────────

  Future<SavedMatrix> saveMatrix(SavedMatrix matrix) async {
    final db = await database;
    final map = matrix.toMap();
    final existing = await db.query(
      'saved_matrices',
      where: 'name = ?',
      whereArgs: [matrix.name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      final existingId = existing.first['id'] as int;
      final updateMap = Map<String, dynamic>.from(map);
      updateMap.remove('id');
      updateMap['updated_at'] = DateTime.now().toIso8601String();
      await db.update(
        'saved_matrices',
        updateMap,
        where: 'name = ?',
        whereArgs: [matrix.name],
      );
      return matrix.copyWith(id: existingId);
    } else {
      final id = await db.insert(
        'saved_matrices',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return matrix.copyWith(id: id);
    }
  }

  Future<SavedMatrix?> loadMatrix(String name) async {
    final db = await database;
    final rows = await db.query(
      'saved_matrices',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SavedMatrix.fromMap(rows.first);
  }

  Future<int> deleteMatrix(String name) async {
    final db = await database;
    return await db.delete(
      'saved_matrices',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<List<SavedMatrix>> getAllMatrices() async {
    final db = await database;
    final rows = await db.query(
      'saved_matrices',
      orderBy: 'name ASC',
    );
    return rows.map((row) => SavedMatrix.fromMap(row)).toList();
  }

  // ─── Saved Graphs ────────────────────────────────────────────────────────────

  Future<SavedGraph> saveGraph(SavedGraph graph) async {
    final db = await database;
    final map = graph.toMap();
    if (graph.id == 0) {
      final id = await db.insert(
        'saved_graphs',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return graph.copyWith(id: id);
    } else {
      final updateMap = Map<String, dynamic>.from(map);
      updateMap['id'] = graph.id;
      await db.insert(
        'saved_graphs',
        updateMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return graph;
    }
  }

  Future<SavedGraph?> loadGraph(int id) async {
    final db = await database;
    final rows = await db.query(
      'saved_graphs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SavedGraph.fromMap(rows.first);
  }

  Future<int> deleteGraph(int id) async {
    final db = await database;
    return await db.delete(
      'saved_graphs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SavedGraph>> getAllGraphs() async {
    final db = await database;
    final rows = await db.query(
      'saved_graphs',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => SavedGraph.fromMap(row)).toList();
  }

  // ─── Stat Datasets ───────────────────────────────────────────────────────────

  Future<StatDataset> saveDataset(StatDataset dataset) async {
    final db = await database;
    final map = dataset.toMap();
    if (dataset.id == 0) {
      final id = await db.insert(
        'stat_datasets',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return dataset.copyWith(id: id);
    } else {
      final updateMap = Map<String, dynamic>.from(map);
      updateMap['id'] = dataset.id;
      updateMap['updated_at'] = DateTime.now().toIso8601String();
      await db.insert(
        'stat_datasets',
        updateMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return dataset;
    }
  }

  Future<StatDataset?> loadDataset(int id) async {
    final db = await database;
    final rows = await db.query(
      'stat_datasets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StatDataset.fromMap(rows.first);
  }

  Future<int> deleteDataset(int id) async {
    final db = await database;
    return await db.delete(
      'stat_datasets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<StatDataset>> getAllDatasets() async {
    final db = await database;
    final rows = await db.query(
      'stat_datasets',
      orderBy: 'updated_at DESC',
    );
    return rows.map((row) => StatDataset.fromMap(row)).toList();
  }

  // ─── Physical Constants (for ConstantsService) ───────────────────────────────

  Future<bool> isConstantsTableSeeded() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM physical_constants',
    );
    final count = result.first['count'] as int? ?? 0;
    return count > 0;
  }

  Future<void> insertConstant(Map<String, dynamic> constantMap) async {
    final db = await database;
    await db.insert(
      'physical_constants',
      constantMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertConstantsBatch(List<Map<String, dynamic>> constants) async {
    final db = await database;
    final batch = db.batch();
    for (final c in constants) {
      batch.insert(
        'physical_constants',
        c,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> searchConstants(String query) async {
    final db = await database;
    if (query.trim().isEmpty) {
      return await db.query(
        'physical_constants',
        orderBy: 'category ASC, name ASC',
      );
    }
    final pattern = '%${query.trim()}%';
    return await db.query(
      'physical_constants',
      where: 'name LIKE ? OR symbol LIKE ? OR category LIKE ?',
      whereArgs: [pattern, pattern, pattern],
      orderBy: 'category ASC, name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getConstantsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'physical_constants',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllConstants() async {
    final db = await database;
    return await db.query(
      'physical_constants',
      orderBy: 'category ASC, name ASC',
    );
  }

  // ─── Favorites (used by FavoritesService) ────────────────────────────────────

  Future<int> insertFavorite(Map<String, dynamic> favoriteMap) async {
    final db = await database;
    return await db.insert(
      'favorites',
      favoriteMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await database;
    return await db.query(
      'favorites',
      orderBy: 'sort_order ASC',
    );
  }

  Future<int> deleteFavorite(int id) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFavoriteOrder(int id, int sortOrder) async {
    final db = await database;
    await db.update(
      'favorites',
      {'sort_order': sortOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFavoritesOrderBatch(List<Map<String, dynamic>> updates) async {
    final db = await database;
    final batch = db.batch();
    for (final update in updates) {
      batch.update(
        'favorites',
        {'sort_order': update['sort_order']},
        where: 'id = ?',
        whereArgs: [update['id']],
      );
    }
    await batch.commit(noResult: true);
  }
}
