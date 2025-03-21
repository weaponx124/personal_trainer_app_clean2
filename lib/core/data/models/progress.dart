class Progress {
  final String id;
  final double weight;
  final int date;

  Progress({
    required this.id,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date,
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as String,
      weight: map['weight'] as double,
      date: map['date'] as int,
    );
  }
}