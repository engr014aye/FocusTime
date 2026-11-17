import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/database/app_database.dart';
import '../core/models/focus_session.dart';

class DailyActivity {
  final String dayName;
  final String dateString;
  final int focusMinutes;

  const DailyActivity({
    required this.dayName,
    required this.dateString,
    required this.focusMinutes,
  });
}

class StatsController extends ChangeNotifier {
  static final StatsController instance = StatsController._internal();

  StatsController._internal();

  int _minutesToday = 0;
  int _minutesOverall = 0;
  int _currentStreak = 0;
  List<FocusSession> _recentSessions = [];
  List<DailyActivity> _weeklyActivity = [];
  Map<String, int> _categoryMinutes = {};
  bool _isLoading = true;

  int get minutesToday => _minutesToday;
  int get minutesOverall => _minutesOverall;
  int get currentStreak => _currentStreak;
  List<FocusSession> get recentSessions => _recentSessions;
  List<DailyActivity> get weeklyActivity => _weeklyActivity;
  Map<String, int> get categoryMinutes => _categoryMinutes;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    _minutesToday = await AppDatabase.instance.getTotalFocusMinutesToday(todayStr);
    _minutesOverall = await AppDatabase.instance.getTotalFocusMinutesOverall();
    _currentStreak = await AppDatabase.instance.getStreakCount();
    _recentSessions = await AppDatabase.instance.getAllFocusSessions();

    // Calculate last 7 days activity
    final List<DailyActivity> weekly = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      final mins = await AppDatabase.instance.getTotalFocusMinutesToday(dateStr);
      weekly.add(DailyActivity(
        dayName: dayName,
        dateString: dateStr,
        focusMinutes: mins,
      ));
    }
    _weeklyActivity = weekly;

    // Calculate category breakdown
    final Map<String, int> catMap = {};
    for (var s in _recentSessions) {
      catMap[s.category] = (catMap[s.category] ?? 0) + s.durationMinutes;
    }
    _categoryMinutes = catMap;

    _isLoading = false;
    notifyListeners();
  }
}
