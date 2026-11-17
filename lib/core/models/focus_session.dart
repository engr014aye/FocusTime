class FocusSession {
  final String id;
  final String? routineId;
  final String title;
  final String category;
  final int durationSeconds;
  final String? soundscapeUsed;
  final DateTime completedAt;
  final String dateString; // "YYYY-MM-DD"

  const FocusSession({
    required this.id,
    this.routineId,
    required this.title,
    required this.category,
    required this.durationSeconds,
    this.soundscapeUsed,
    required this.completedAt,
    required this.dateString,
  });

  int get durationMinutes => (durationSeconds / 60).round();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routine_id': routineId,
      'title': title,
      'category': category,
      'duration_seconds': durationSeconds,
      'soundscape_used': soundscapeUsed,
      'completed_at': completedAt.toIso8601String(),
      'date_string': dateString,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      routineId: map['routine_id'] as String?,
      title: map['title'] as String,
      category: (map['category'] as String?) ?? 'Deep Work',
      durationSeconds: (map['duration_seconds'] as int?) ?? 1500,
      soundscapeUsed: map['soundscape_used'] as String?,
      completedAt: DateTime.tryParse(map['completed_at'] as String) ?? DateTime.now(),
      dateString: map['date_string'] as String,
    );
  }
}
