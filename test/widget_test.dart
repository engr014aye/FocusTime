import 'package:flutter_test/flutter_test.dart';
import 'package:focustime/core/models/routine_item.dart';
import 'package:focustime/core/models/focus_session.dart';
import 'package:focustime/core/models/timebox_preset.dart';
import 'package:focustime/core/models/quote.dart';

void main() {
  group('FocusTime Model Unit Tests', () {
    test('RoutineItem serialization test', () {
      final now = DateTime.now();
      final item = RoutineItem(
        id: 'test_1',
        title: 'Hydration Sprint',
        subtitle: '500ml water',
        category: 'Health',
        block: 'Morning',
        icon: 'drop_fill',
        targetMinutes: 5,
        colorHex: 0xFF0284C7,
        createdAt: now,
      );

      final map = item.toMap();
      expect(map['id'], 'test_1');
      expect(map['title'], 'Hydration Sprint');
      expect(map['target_minutes'], 5);

      final restored = RoutineItem.fromMap(map);
      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.category, item.category);
    });

    test('FocusSession duration calculation test', () {
      final now = DateTime.now();
      final session = FocusSession(
        id: 'sess_1',
        title: 'Deep Architecture Block',
        category: 'Deep Work',
        durationSeconds: 1500,
        completedAt: now,
        dateString: '2026-11-17',
      );

      expect(session.durationMinutes, 25);
      expect(session.dateString, '2026-11-17');
    });

    test('TimeboxPreset JSON parsing test', () {
      final json = {
        'id': 'classic',
        'title': 'Classic Flow',
        'focusMinutes': 25,
        'breakMinutes': 5,
        'longBreakMinutes': 15,
        'sessionsBeforeLongBreak': 4,
        'tag': 'Deep Work',
        'recommendedSound': 'rain.wav',
      };

      final preset = TimeboxPreset.fromJson(json);
      expect(preset.id, 'classic');
      expect(preset.focusMinutes, 25);
      expect(preset.breakMinutes, 5);
    });

    test('Quote JSON parsing test', () {
      final json = {
        'quote': 'Focus is a muscle.',
        'author': 'Flow Principles',
      };

      final quote = Quote.fromJson(json);
      expect(quote.quote, 'Focus is a muscle.');
      expect(quote.author, 'Flow Principles');
    });
  });
}
