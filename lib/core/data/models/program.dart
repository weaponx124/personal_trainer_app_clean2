class Program {
  final String id;
  final String name;
  final String description;

  Program({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'] as String? ?? 'unknown_id',
      name: map['name'] as String? ?? 'Unknown Program',
      description: map['description'] as String? ?? '',
    );
  }
}