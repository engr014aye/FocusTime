class TimeboxPreset {
  final String id;
  final String title;
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final String tag;
  final String recommendedSound;

  const TimeboxPreset({
    required this.id,
    required this.title,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
    required this.sessionsBeforeLongBreak,
    required this.tag,
    required this.recommendedSound,
  });

  factory TimeboxPreset.fromJson(Map<String, dynamic> json) {
    return TimeboxPreset(
      id: json['id'] as String,
      title: json['title'] as String,
      focusMinutes: (json['focusMinutes'] as int?) ?? 25,
      breakMinutes: (json['breakMinutes'] as int?) ?? 5,
      longBreakMinutes: (json['longBreakMinutes'] as int?) ?? 15,
      sessionsBeforeLongBreak: (json['sessionsBeforeLongBreak'] as int?) ?? 4,
      tag: (json['tag'] as String?) ?? 'Deep Work',
      recommendedSound: (json['recommendedSound'] as String?) ?? 'rain.wav',
    );
  }
}
