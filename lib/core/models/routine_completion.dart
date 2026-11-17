class RoutineCompletion {
  final String id;
  final String routineId;
  final String dateString; // "YYYY-MM-DD"
  final DateTime completedAt;

  const RoutineCompletion({
    required this.id,
    required this.routineId,
    required this.dateString,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routine_id': routineId,
      'date_string': dateString,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory RoutineCompletion.fromMap(Map<String, dynamic> map) {
    return RoutineCompletion(
      id: map['id'] as String,
      routineId: map['routine_id'] as String,
      dateString: map['date_string'] as String,
      completedAt: DateTime.tryParse(map['completed_at'] as String) ?? DateTime.now(),
    );
  }
}
