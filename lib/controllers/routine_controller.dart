import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/database/app_database.dart';
import '../core/models/routine_item.dart';
import '../core/models/quote.dart';
import '../core/services/haptic_service.dart';

class RoutineController extends ChangeNotifier {
  static final RoutineController instance = RoutineController._internal();

  RoutineController._internal();

  List<RoutineItem> _routines = [];
  Set<String> _completedIds = {};
  int _streakCount = 0;
  bool _isLoading = true;
  String _selectedDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<Quote> _quotes = [];
  Quote? _dailyQuote;

  List<RoutineItem> get routines => _routines;
  Set<String> get completedIds => _completedIds;
  int get streakCount => _streakCount;
  bool get isLoading => _isLoading;
  String get selectedDateString => _selectedDateString;
  Quote? get dailyQuote => _dailyQuote;

  List<RoutineItem> get morningRoutines =>
      _routines.where((r) => r.block == 'Morning').toList();
  List<RoutineItem> get afternoonRoutines =>
      _routines.where((r) => r.block == 'Afternoon').toList();
  List<RoutineItem> get eveningRoutines =>
      _routines.where((r) => r.block == 'Evening').toList();

  int get totalCount => _routines.length;
  int get completedCount =>
      _routines.where((r) => _completedIds.contains(r.id)).length;
  double get completionPercentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  bool isCompleted(String routineId) => _completedIds.contains(routineId);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _loadQuotes();
    await refresh();
  }

  Future<void> _loadQuotes() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/quotes.json');
      final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
      _quotes = list.map((q) => Quote.fromJson(q as Map<String, dynamic>)).toList();
      if (_quotes.isNotEmpty) {
        final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        _dailyQuote = _quotes[dayOfYear % _quotes.length];
      }
    } catch (_) {}
  }

  Future<void> refresh() async {
    _routines = await AppDatabase.instance.getRoutines();
    final completedList =
        await AppDatabase.instance.getCompletedRoutineIds(_selectedDateString);
    _completedIds = completedList.toSet();
    _streakCount = await AppDatabase.instance.getStreakCount();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDateString = DateFormat('yyyy-MM-dd').format(date);
    final completedList =
        await AppDatabase.instance.getCompletedRoutineIds(_selectedDateString);
    _completedIds = completedList.toSet();
    notifyListeners();
  }

  Future<void> toggleCompletion(String routineId) async {
    HapticService.instance.medium();
    final wasCompleted = _completedIds.contains(routineId);
    if (wasCompleted) {
      _completedIds.remove(routineId);
    } else {
      _completedIds.add(routineId);
      HapticService.instance.success();
    }
    notifyListeners();

    await AppDatabase.instance.toggleRoutineCompletion(routineId, _selectedDateString);
    _streakCount = await AppDatabase.instance.getStreakCount();
    notifyListeners();
  }

  Future<void> addRoutine(RoutineItem item) async {
    await AppDatabase.instance.insertRoutine(item);
    HapticService.instance.light();
    await refresh();
  }

  Future<void> deleteRoutine(String id) async {
    await AppDatabase.instance.deleteRoutine(id);
    HapticService.instance.light();
    await refresh();
  }
}
