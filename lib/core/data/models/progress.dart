class Progress {
  final String id;
  final int date;
  final double weight;
  final double? bodyFat;
  final Map<String, dynamic>? measurements;

  Progress({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.measurements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
      'bodyFat': bodyFat,
      'measurements': measurements,
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as String? ?? 'unknown_id',
      date: map['date'] as int? ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      bodyFat: (map['bodyFat'] as num?)?.toDouble(),
      measurements: map['measurements'] as Map<String, dynamic>?,
    );
  }
}