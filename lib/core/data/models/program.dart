class Program {
  final String id;
  final String name;
  final String? description; // Made optional
  final Map<String, dynamic> oneRMs;
  final Map<String, dynamic> details; // Added
  final bool completed; // Added
  final String startDate; // Added
  final int currentWeek; // Added
  final int currentSession; // Added
  final int sessionsCompleted; // Added

  Program({
    required this.id,
    required this.name,
    this.description,
    required this.oneRMs,
    required this.details,
    required this.completed,
    required this.startDate,
    required this.currentWeek,
    required this.currentSession,
    required this.sessionsCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'oneRMs': oneRMs,
      'details': details,
      'completed': completed,
      'startDate': startDate,
      'currentWeek': currentWeek,
      'currentSession': currentSession,
      'sessionsCompleted': sessionsCompleted,
    };
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      oneRMs: Map<String, dynamic>.from(map['oneRMs'] as Map),
      details: Map<String, dynamic>.from(map['details'] as Map? ?? {}),
      completed: map['completed'] as bool? ?? false,
      startDate: map['startDate'] as String? ?? '',
      currentWeek: map['currentWeek'] as int? ?? 1,
      currentSession: map['currentSession'] as int? ?? 1,
      sessionsCompleted: map['sessionsCompleted'] as int? ?? 0,
    );
  }
}