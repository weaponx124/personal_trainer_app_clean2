import 'dart:convert';

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
      'exercises': jsonEncode(exercises), // Serialize to JSON string
      'timestamp': timestamp,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    // Handle exercises as either List<dynamic> (from SharedPreferences) or JSON string (from SQLite)
    List<Map<String, dynamic>> exercisesValue;
    if (map['exercises'] is String) {
      exercisesValue = (jsonDecode(map['exercises'] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else {
      exercisesValue = (map['exercises'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
          [];
    }

    return Workout(
      id: map['id'] as String,
      programId: map['programId'] as String,
      name: map['name'] as String,
      exercises: exercisesValue,
      timestamp: map['timestamp'] as int,
    );
  }
}