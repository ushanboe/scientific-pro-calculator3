// Step 1: Inventory
// This file DEFINES: ConstantsService singleton class with methods:
//   - instance (static singleton)
//   - seedDatabaseIfNeeded(): loads JSON asset, inserts 90+ constants into SQLite if not already seeded
//   - getAllConstants(): returns all constants from SQLite
//   - search(String query): LIKE filter on name/symbol/category
//   - getByCategory(String category): filter by category
//   - getCategories(): distinct list of categories
//   - getById(int id): single constant lookup
//
// This file USES from other files:
//   - PhysicalConstant model (lib/models/physical_constant.dart) — fromMap(), toMap()
//   - HistoryService (lib/services/history_service.dart) — for the shared SQLite database
//
// Step 2: Connections
// - Called by main.dart: ConstantsService.instance.seedDatabaseIfNeeded()
// - Called by ConstantsScreen: search(), getAllConstants(), getByCategory(), getCategories()
// - HistoryService owns the SQLite database and creates the physical_constants table
//   so ConstantsService needs access to that same database
//
// Step 3: User Journey Trace
// App starts → main.dart calls seedDatabaseIfNeeded() → checks SharedPreferences flag
//   → if not seeded, loads JSON from assets → inserts each constant via HistoryService.database
// ConstantsScreen opens → calls getAllConstants() or search() → returns List<PhysicalConstant>
// User searches "planck" → search("planck") → LIKE query on name/symbol/category
// User filters by "Universal" → getByCategory("Universal") → returns filtered list
//
// Step 4: Layout Sanity
// Pure service — no widgets
// Must use HistoryService.instance.database to get the shared DB
// seedDatabaseIfNeeded uses SharedPreferences to track if seeding has been done
// JSON asset path: assets/data/physical_constants.json (declared in pubspec)
// The physical_constants.json is at lib/assets/data/physical_constants.json in the manifest
// but referenced as assets/data/physical_constants.json in Flutter asset bundle

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scientific_pro_calculator/models/physical_constant.dart';
import 'package:scientific_pro_calculator/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ConstantsService {
  static final ConstantsService instance = ConstantsService._internal();
  ConstantsService._internal();

  static const String _seededKey = 'constants_seeded_v1';

  Future<Database> get _db async => await HistoryService.instance.database;

  /// Seeds the database with 90+ physical constants from the JSON asset file.
  /// Only runs once per install (tracked via SharedPreferences flag).
  Future<void> seedDatabaseIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seededKey) ?? false;
    if (alreadySeeded) return;

    try {
      final db = await _db;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM physical_constants'),
      ) ?? 0;
      if (count > 0) {
        await prefs.setBool(_seededKey, true);
        return;
      }

      final jsonString = await rootBundle.loadString('assets/data/physical_constants.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      await db.transaction((txn) async {
        for (final item in jsonList) {
          final map = item as Map<String, dynamic>;
          await txn.insert(
            'physical_constants',
            {
              'id': map['id'] as int,
              'name': map['name'] as String,
              'symbol': map['symbol'] as String,
              'value': map['value'] as String,
              'unit': map['unit'] as String,
              'uncertainty': map['uncertainty'] as String?,
              'category': map['category'] as String,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });

      await prefs.setBool(_seededKey, true);
      print('SCIENTIFIC_PRO_CALC constants seeded: ${jsonList.length} constants');
    } catch (e) {
      print('SCIENTIFIC_PRO_CALC constants seed error: $e');
      rethrow;
    }
  }

  /// Returns all physical constants sorted by category then name.
  Future<List<PhysicalConstant>> getAllConstants() async {
    final db = await _db;
    final rows = await db.query(
      'physical_constants',
      orderBy: 'category ASC, name ASC',
    );
    return rows.map(PhysicalConstant.fromMap).toList();
  }

  /// Searches constants by name, symbol, or category using LIKE filter.
  Future<List<PhysicalConstant>> search(String query) async {
    if (query.trim().isEmpty) return getAllConstants();
    final db = await _db;
    final pattern = '%${query.trim()}%';
    final rows = await db.query(
      'physical_constants',
      where: 'name LIKE ? OR symbol LIKE ? OR category LIKE ?',
      whereArgs: [pattern, pattern, pattern],
      orderBy: 'category ASC, name ASC',
    );
    return rows.map(PhysicalConstant.fromMap).toList();
  }

  /// Returns all constants in a specific category.
  Future<List<PhysicalConstant>> getByCategory(String category) async {
    final db = await _db;
    final rows = await db.query(
      'physical_constants',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return rows.map(PhysicalConstant.fromMap).toList();
  }

  /// Returns a distinct list of all categories.
  Future<List<String>> getCategories() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT DISTINCT category FROM physical_constants ORDER BY category ASC',
    );
    return rows.map((r) => r['category'] as String).toList();
  }

  /// Returns a single constant by its ID, or null if not found.
  Future<PhysicalConstant?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'physical_constants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PhysicalConstant.fromMap(rows.first);
  }

  /// Returns a constant by its symbol (e.g. 'c', 'h', 'e'), or null if not found.
  Future<PhysicalConstant?> getBySymbol(String symbol) async {
    final db = await _db;
    final rows = await db.query(
      'physical_constants',
      where: 'symbol = ?',
      whereArgs: [symbol],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PhysicalConstant.fromMap(rows.first);
  }

  /// Returns the total count of seeded constants.
  Future<int> getCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) FROM physical_constants');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clears the seeded flag so the next app launch re-seeds from JSON.
  /// Used for testing or after a schema migration.
  Future<void> resetSeedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seededKey);
  }
}