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
  final List<Map<String, dynamic>> workouts; // Add workouts property

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
    this.workouts = const [], // Default to empty list
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'oneRMs': oneRMs,
      'currentWeek': currentWeek,
      'currentSession': currentSession,
      'sessionsCompleted': sessionsCompleted,
      'startDate': startDate,
      'completed': completed,
      'workouts': workouts, // Include workouts in the map
    };
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'] as String,
      name: map['name'] as String,
      details: Map<String, dynamic>.from(map['details']),
      oneRMs: Map<String, dynamic>.from(map['oneRMs']),
      currentWeek: map['currentWeek'] as int,
      currentSession: map['currentSession'] as int,
      sessionsCompleted: map['sessionsCompleted'] as int,
      startDate: map['startDate'] as String,
      completed: map['completed'] as bool,
      workouts: (map['workouts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [], // Handle workouts
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
    List<Map<String, dynamic>>? workouts, // Add workouts parameter
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
      workouts: workouts ?? this.workouts, // Include workouts in copyWith
    );
  }
}