class Workout {
  final String id;
  final String programId;
  final String name;
  final List<Map<String, dynamic>> exercises;
  final int timestamp;

  Workout({
    required this.id,
    required this.programId,
    required this.name,
    required this.exercises,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'programId': programId,
      'name': name,
      'exercises': exercises,
      'timestamp': timestamp,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String? ?? 'unknown_id',
      programId: map['programId'] as String? ?? 'unknown_program_id',
      name: map['name'] as String? ?? 'Unknown Workout',
      exercises: (map['exercises'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      timestamp: map['timestamp'] as int? ?? 0,
    );
  }
}