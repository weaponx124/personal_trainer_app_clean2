class ProgramLogic {
  static double calculateWorkingWeight(double oneRM, double percentage, {String unit = 'lbs'}) {
    return (oneRM * percentage).roundToDouble();
  }

  static Map<String, dynamic> calculate531(
      Map<String, dynamic> oneRMs, int week, String lift) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    final percentages = week == 1
        ? [0.65, 0.75, 0.85]
        : week == 2
        ? [0.70, 0.80, 0.90]
        : week == 3
        ? [0.75, 0.85, 0.95]
        : [0.40, 0.50, 0.60];
    final reps = week == 4 ? [5, 5, 5] : [3, 3, 3];
    final weights = percentages.map((p) => (trainingMax * p).roundToDouble()).toList();
    return {
      'sets': List.generate(3, (i) => {
        'weight': weights[i],
        'reps': reps[i],
      }),
    };
  }

  static Map<String, dynamic> calculateTexasMethod(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    if (day == 'Volume') {
      return {
        'sets': List.generate(5, (_) => {
          'weight': (trainingMax * 0.7).roundToDouble(),
          'reps': 5,
        }),
      };
    } else if (day == 'Recovery') {
      return {
        'sets': List.generate(3, (_) => {
          'weight': (trainingMax * 0.5).roundToDouble(),
          'reps': 5,
        }),
      };
    } else {
      return {
        'sets': [
          {'weight': (trainingMax * 0.9).roundToDouble(), 'reps': 3},
        ],
      };
    }
  }

  static Map<String, dynamic> calculateMadcow(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    if (day == 'Monday') {
      return {
        'sets': List.generate(5, (i) => {
          'weight': (trainingMax * (0.6 + i * 0.05)).roundToDouble(),
          'reps': 5,
        }),
      };
    } else if (day == 'Wednesday') {
      return {
        'sets': List.generate(4, (i) => {
          'weight': (trainingMax * (0.5 + i * 0.05)).roundToDouble(),
          'reps': 5,
        }),
      };
    } else {
      return {
        'sets': [
          {'weight': (trainingMax * 0.9).roundToDouble(), 'reps': 3},
        ],
      };
    }
  }

  static Map<String, dynamic> calculateSmolov(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    if (week <= 4) {
      final schedule = [
        {'sets': 4, 'reps': 6, 'percentage': 0.70},
        {'sets': 5, 'reps': 7, 'percentage': 0.75},
        {'sets': 7, 'reps': 5, 'percentage': 0.80},
        {'sets': 10, 'reps': 3, 'percentage': 0.85},
      ];
      final dayIndex = (int.parse(day.split(' ')[1]) - 1) % 4;
      final daySchedule = schedule[dayIndex];
      return {
        'sets': List.generate(
          (daySchedule['sets'] as num?)?.toInt() ?? 0,
              (_) => {
            'weight': (trainingMax * (daySchedule['percentage'] as double)).roundToDouble(),
            'reps': (daySchedule['reps'] as num?)?.toInt() ?? 0,
          },
        ),
      };
    } else {
      return {
        'sets': [
          {'weight': (trainingMax * 0.5).roundToDouble(), 'reps': 5},
        ],
      };
    }
  }

  static Map<String, dynamic> calculateRussianSquat(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.8;
    final schedule = [
      {'sets': 6, 'reps': 2, 'percentage': 0.80},
      {'sets': 7, 'reps': 3, 'percentage': 0.80},
      {'sets': 8, 'reps': 2, 'percentage': 0.80},
    ];
    final dayIndex = (int.parse(day.split(' ')[1]) - 1) % 3;
    final daySchedule = schedule[dayIndex];
    return {
      'sets': List.generate(
        (daySchedule['sets'] as num?)?.toInt() ?? 0,
            (_) => {
          'weight': (trainingMax * (daySchedule['percentage'] as double)).roundToDouble(),
          'reps': (daySchedule['reps'] as num?)?.toInt() ?? 0,
        },
      ),
    };
  }

  static Map<String, dynamic> calculateCandito(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    if (week == 1 || week == 2) {
      return {
        'sets': List.generate(4, (_) => {
          'weight': (trainingMax * 0.675).roundToDouble(),
          'reps': 10,
        }),
      };
    } else if (week == 3 || week == 4) {
      return {
        'sets': List.generate(3, (_) => {
          'weight': (trainingMax * 0.775).roundToDouble(),
          'reps': 6,
        }),
      };
    } else {
      return {
        'sets': [
          {'weight': (trainingMax * 0.9).roundToDouble(), 'reps': 3},
        ],
      };
    }
  }

  static Map<String, dynamic> calculateStartingStrength(
      Map<String, dynamic> oneRMs, int week, String lift, String day) {
    final oneRM = oneRMs[lift] ?? 0.0;
    final trainingMax = oneRM * 0.9;
    return {
      'sets': List.generate(3, (_) => {
        'weight': (trainingMax * 0.7).roundToDouble(),
        'reps': 5,
      }),
    };
  }
}