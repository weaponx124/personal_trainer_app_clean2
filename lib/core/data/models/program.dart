import 'dart:convert';

class Program {
  final String id;
  final String name;
  final Map<String, dynamic> details;
  final Map<String, dynamic> oneRMs;
  final int currentWeek;
  final int currentSession;
  final int sessionsCompleted;
  final String startDate;
  final bool completed;
  final List<Map<String, dynamic>> workouts;

  Program({
    required this.id,
    required this.name,
    required this.details,
    required this.oneRMs,
    required this.currentWeek,
    required this.currentSession,
    required this.sessionsCompleted,
    required this.startDate,
    this.completed = false,
    this.workouts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'details': jsonEncode(details), // Serialize to JSON string
      'oneRMs': jsonEncode(oneRMs), // Serialize to JSON string
      'currentWeek': currentWeek,
      'currentSession': currentSession,
      'sessionsCompleted': sessionsCompleted,
      'startDate': startDate,
      'completed': completed ? 1 : 0, // Convert bool to int
      'workouts': jsonEncode(workouts), // Serialize to JSON string
    };
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    // Handle details as either Map<String, dynamic> (from SharedPreferences) or JSON string (from SQLite)
    Map<String, dynamic> detailsValue;
    if (map['details'] is String) {
      detailsValue = Map<String, dynamic>.from(jsonDecode(map['details'] as String));
    } else {
      detailsValue = Map<String, dynamic>.from(map['details'] ?? {});
    }

    // Handle oneRMs as either Map<String, dynamic> (from SharedPreferences) or JSON string (from SQLite)
    Map<String, dynamic> oneRMsValue;
    if (map['oneRMs'] is String) {
      oneRMsValue = Map<String, dynamic>.from(jsonDecode(map['oneRMs'] as String));
    } else {
      oneRMsValue = Map<String, dynamic>.from(map['oneRMs'] ?? {});
    }

    // Handle completed as either bool (from SharedPreferences) or int (from SQLite)
    bool completedValue;
    if (map['completed'] is bool) {
      completedValue = map['completed'] as bool;
    } else {
      completedValue = (map['completed'] as int? ?? 0) == 1;
    }

    // Handle workouts as either List<dynamic> (from SharedPreferences) or JSON string (from SQLite)
    List<Map<String, dynamic>> workoutsValue;
    if (map['workouts'] is String) {
      workoutsValue = (jsonDecode(map['workouts'] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else {
      workoutsValue = (map['workouts'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
          [];
    }

    return Program(
      id: map['id'] as String,
      name: map['name'] as String,
      details: detailsValue,
      oneRMs: oneRMsValue,
      currentWeek: map['currentWeek'] as int,
      currentSession: map['currentSession'] as int,
      sessionsCompleted: map['sessionsCompleted'] as int,
      startDate: map['startDate'] as String,
      completed: completedValue,
      workouts: workoutsValue,
    );
  }

  Program copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? details,
    Map<String, dynamic>? oneRMs,
    int? currentWeek,
    int? currentSession,
    int? sessionsCompleted,
    String? startDate,
    bool? completed,
    List<Map<String, dynamic>>? workouts,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      details: details ?? this.details,
      oneRMs: oneRMs ?? this.oneRMs,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      startDate: startDate ?? this.startDate,
      completed: completed ?? this.completed,
      workouts: workouts ?? this.workouts,
    );
  }
}