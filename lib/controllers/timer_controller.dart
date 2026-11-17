import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/database/app_database.dart';
import '../core/models/focus_session.dart';
import '../core/models/routine_item.dart';
import '../core/services/audio_service.dart';
import '../core/services/haptic_service.dart';
import 'routine_controller.dart';

enum TimerMode { focus, shortBreak, longBreak }
enum TimerStatus { idle, running, paused, completed }

class TimerController extends ChangeNotifier {
  static final TimerController instance = TimerController._internal();

  TimerController._internal();

  TimerMode _mode = TimerMode.focus;
  TimerStatus _status = TimerStatus.idle;

  int _targetSeconds = 25 * 60; // Default 25 mins
  int _remainingSeconds = 25 * 60;
  Timer? _timer;

  RoutineItem? _activeRoutine;
  AmbientSound? _activeSound;
  int _sessionsCompletedToday = 0;

  TimerMode get mode => _mode;
  TimerStatus get status => _status;
  int get targetSeconds => _targetSeconds;
  int get remainingSeconds => _remainingSeconds;
  RoutineItem? get activeRoutine => _activeRoutine;
  AmbientSound? get activeSound => _activeSound;
  int get sessionsCompletedToday => _sessionsCompletedToday;

  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isIdle => _status == TimerStatus.idle;

  double get progress {
    if (_targetSeconds == 0) return 0.0;
    return (1.0 - (_remainingSeconds / _targetSeconds)).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get modeLabel {
    switch (_mode) {
      case TimerMode.focus:
        return _activeRoutine != null ? _activeRoutine!.title : 'Deep Focus Block';
      case TimerMode.shortBreak:
        return 'Short Mindful Break';
      case TimerMode.longBreak:
        return 'Long Recovery Break';
    }
  }

  Future<void> init() async {
    _activeSound = AudioService.instance.availableSounds.first; // Rain Shower
    await _loadTodaySessionCount();
  }

  Future<void> _loadTodaySessionCount() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final sessions = await AppDatabase.instance.getFocusSessionsForDate(today);
    _sessionsCompletedToday = sessions.length;
    notifyListeners();
  }

  void setDuration(int minutes) {
    if (isRunning) return;
    _targetSeconds = minutes * 60;
    _remainingSeconds = _targetSeconds;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  void setMode(TimerMode newMode) {
    if (isRunning) return;
    _mode = newMode;
    switch (newMode) {
      case TimerMode.focus:
        _targetSeconds = (_activeRoutine?.targetMinutes ?? 25) * 60;
        break;
      case TimerMode.shortBreak:
        _targetSeconds = 5 * 60;
        break;
      case TimerMode.longBreak:
        _targetSeconds = 15 * 60;
        break;
    }
    _remainingSeconds = _targetSeconds;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  void setActiveRoutine(RoutineItem? routine) {
    _activeRoutine = routine;
    if (routine != null) {
      _mode = TimerMode.focus;
      _targetSeconds = routine.targetMinutes * 60;
      _remainingSeconds = _targetSeconds;
      _status = TimerStatus.idle;
    }
    notifyListeners();
  }

  void setActiveSound(AmbientSound? sound) {
    _activeSound = sound;
    if (isRunning && sound != null) {
      AudioService.instance.playAmbient(sound);
    }
    notifyListeners();
  }

  void startTimer() {
    HapticService.instance.medium();
    _status = TimerStatus.running;
    notifyListeners();

    if (_mode == TimerMode.focus && _activeSound != null) {
      AudioService.instance.playAmbient(_activeSound!);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }

  void pauseTimer() {
    HapticService.instance.light();
    _timer?.cancel();
    _status = TimerStatus.paused;
    AudioService.instance.stopAmbient();
    notifyListeners();
  }

  void resumeTimer() {
    startTimer();
  }

  void resetTimer() {
    HapticService.instance.light();
    _timer?.cancel();
    _remainingSeconds = _targetSeconds;
    _status = TimerStatus.idle;
    AudioService.instance.stopAmbient();
    notifyListeners();
  }

  void skipTimer() {
    HapticService.instance.medium();
    _timer?.cancel();
    AudioService.instance.stopAmbient();
    _switchModeAfterCompletion();
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    _status = TimerStatus.completed;
    AudioService.instance.stopAmbient();

    // Play completion chime & haptic celebration
    HapticService.instance.success();
    await AudioService.instance.playZenBell();

    if (_mode == TimerMode.focus) {
      _sessionsCompletedToday++;
      final now = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(now);

      final session = FocusSession(
        id: 'sess_${now.millisecondsSinceEpoch}',
        routineId: _activeRoutine?.id,
        title: _activeRoutine?.title ?? 'Deep Focus Block',
        category: _activeRoutine?.category ?? 'Deep Work',
        durationSeconds: _targetSeconds,
        soundscapeUsed: _activeSound?.name,
        completedAt: now,
        dateString: dateString,
      );

      await AppDatabase.instance.insertFocusSession(session);

      // Also if linked to a routine, mark routine complete
      if (_activeRoutine != null) {
        await RoutineController.instance.toggleCompletion(_activeRoutine!.id);
      }
    }

    notifyListeners();
  }

  void _switchModeAfterCompletion() {
    if (_mode == TimerMode.focus) {
      if (_sessionsCompletedToday % 4 == 0 && _sessionsCompletedToday > 0) {
        setMode(TimerMode.longBreak);
      } else {
        setMode(TimerMode.shortBreak);
      }
    } else {
      setMode(TimerMode.focus);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
