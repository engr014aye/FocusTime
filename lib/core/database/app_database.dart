import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/routine_item.dart';
import '../models/routine_completion.dart';
import '../models/focus_session.dart';
import 'database_tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'focustime_routine.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(DatabaseTables.createRoutinesTable);
        await db.execute(DatabaseTables.createRoutineCompletionsTable);
        await db.execute(DatabaseTables.createFocusSessionsTable);
        await db.execute(DatabaseTables.createUserPreferencesTable);
      },
      onOpen: (db) async {
        await _seedInitialRoutinesIfNeeded(db);
      },
    );
  }

  static Future<void> _seedInitialRoutinesIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.routines}'),
    );

    if (count == 0) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/routines.json');
        final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
        final now = DateTime.now();

        final batch = db.batch();
        for (int i = 0; i < data.length; i++) {
          final item = data[i] as Map<String, dynamic>;
          final routine = RoutineItem(
            id: item['id'] as String,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            category: item['category'] as String,
            block: item['block'] as String,
            icon: item['icon'] as String,
            targetMinutes: item['targetMinutes'] as int,
            colorHex: int.parse(item['colorHex'] as String),
            isArchived: false,
            orderIndex: i,
            createdAt: now,
          );
          batch.insert(DatabaseTables.routines, routine.toMap());
        }
        await batch.commit(noResult: true);
      } catch (e) {
        // Fallback gracefully if asset cannot be read
      }
    }
  }

  // Routine CRUD
  Future<List<RoutineItem>> getRoutines() async {
    final db = await database;
    final maps = await db.query(
      DatabaseTables.routines,
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'order_index ASC',
    );
    return maps.map((m) => RoutineItem.fromMap(m)).toList();
  }

  Future<void> insertRoutine(RoutineItem item) async {
    final db = await database;
    await db.insert(
      DatabaseTables.routines,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRoutine(RoutineItem item) async {
    final db = await database;
    await db.update(
      DatabaseTables.routines,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteRoutine(String id) async {
    final db = await database;
    await db.delete(
      DatabaseTables.routines,
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete(
      DatabaseTables.routineCompletions,
      where: 'routine_id = ?',
      whereArgs: [id],
    );
  }

  // Routine Completions
  Future<bool> toggleRoutineCompletion(String routineId, String dateString) async {
    final db = await database;
    final existing = await db.query(
      DatabaseTables.routineCompletions,
      where: 'routine_id = ? AND date_string = ?',
      whereArgs: [routineId, dateString],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        DatabaseTables.routineCompletions,
        where: 'routine_id = ? AND date_string = ?',
        whereArgs: [routineId, dateString],
      );
      return false;
    } else {
      final completion = RoutineCompletion(
        id: '${routineId}_$dateString',
        routineId: routineId,
        dateString: dateString,
        completedAt: DateTime.now(),
      );
      await db.insert(DatabaseTables.routineCompletions, completion.toMap());
      return true;
    }
  }

  Future<List<String>> getCompletedRoutineIds(String dateString) async {
    final db = await database;
    final maps = await db.query(
      DatabaseTables.routineCompletions,
      columns: ['routine_id'],
      where: 'date_string = ?',
      whereArgs: [dateString],
    );
    return maps.map((m) => m['routine_id'] as String).toList();
  }

  Future<int> getStreakCount() async {
    final db = await database;
    // Calculate consecutive days with at least 1 completed routine
    final dates = await db.rawQuery(
      'SELECT DISTINCT date_string FROM ${DatabaseTables.routineCompletions} ORDER BY date_string DESC',
    );

    if (dates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var row in dates) {
      final rowDateStr = row['date_string'] as String;
      final expectedStr =
          "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";

      if (rowDateStr == expectedStr) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // If today has no completion yet, allow yesterday as the continuing streak
        if (streak == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          final yesterdayStr =
              "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
          if (rowDateStr == yesterdayStr) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
        }
        break;
      }
    }

    return streak;
  }

  // Focus Sessions
  Future<void> insertFocusSession(FocusSession session) async {
    final db = await database;
    await db.insert(
      DatabaseTables.focusSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FocusSession>> getFocusSessionsForDate(String dateString) async {
    final db = await database;
    final maps = await db.query(
      DatabaseTables.focusSessions,
      where: 'date_string = ?',
      whereArgs: [dateString],
      orderBy: 'completed_at DESC',
    );
    return maps.map((m) => FocusSession.fromMap(m)).toList();
  }

  Future<List<FocusSession>> getAllFocusSessions() async {
    final db = await database;
    final maps = await db.query(
      DatabaseTables.focusSessions,
      orderBy: 'completed_at DESC',
      limit: 100,
    );
    return maps.map((m) => FocusSession.fromMap(m)).toList();
  }

  Future<int> getTotalFocusMinutesToday(String dateString) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM ${DatabaseTables.focusSessions} WHERE date_string = ?',
      [dateString],
    );
    final totalSec = (res.first['total'] as int?) ?? 0;
    return (totalSec / 60).round();
  }

  Future<int> getTotalFocusMinutesOverall() async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM ${DatabaseTables.focusSessions}',
    );
    final totalSec = (res.first['total'] as int?) ?? 0;
    return (totalSec / 60).round();
  }

  // Key-Value user preferences
  Future<String?> getPreference(String key) async {
    final db = await database;
    final maps = await db.query(
      DatabaseTables.userPreferences,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      DatabaseTables.userPreferences,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
