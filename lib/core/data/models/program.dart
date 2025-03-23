class Program {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> oneRMs;
  final Map<String, dynamic> details;
  final bool completed;
  final String startDate;
  final int currentWeek;
  final int currentSession;
  final int sessionsCompleted;

  Program({
    required this.id,
    required this.name,
    required this.description,
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
      description: map['description'] as String,
      oneRMs: Map<String, dynamic>.from(map['oneRMs'] ?? {}),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      completed: map['completed'] as bool,
      startDate: map['startDate'] as String,
      currentWeek: map['currentWeek'] as int,
      currentSession: map['currentSession'] as int,
      sessionsCompleted: map['sessionsCompleted'] as int,
    );
  }

  Program copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? oneRMs,
    Map<String, dynamic>? details,
    bool? completed,
    String? startDate,
    int? currentWeek,
    int? currentSession,
    int? sessionsCompleted,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      oneRMs: oneRMs ?? this.oneRMs,
      details: details ?? this.details,
      completed: completed ?? this.completed,
      startDate: startDate ?? this.startDate,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }
}