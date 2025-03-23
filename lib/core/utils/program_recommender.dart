import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';

class ProgramRecommender {
  final SettingsRepository _settingsRepository;
  final WorkoutRepository _workoutRepository;

  ProgramRecommender(this._settingsRepository, this._workoutRepository);

  // List of available programs with metadata, aligned with program_selection_screen.dart
  static const List<Map<String, dynamic>> availablePrograms = [
    {
      'name': '5/3/1 Program',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift', 'Overhead'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Texas Method',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Madcow 5x5',
      'duration': '12-16 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Sheiko Beginner',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Sheiko Intermediate',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Sheiko Advanced',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Smolov Base Cycle',
      'duration': '13 weeks',
      'requires1RM': true,
      'lifts': ['Squat'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Smolov Jr. (Bench)',
      'duration': '3-4 weeks',
      'requires1RM': true,
      'lifts': ['Bench'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Candito 6-Week Program',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Push/Pull/Legs (PPL)',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Arnold Split',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Bro Split',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'PHUL',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'PHAT',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'German Volume Training',
      'duration': '4-6 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Starting Strength',
      'duration': '3-6 months',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'StrongLifts 5x5',
      'duration': '3-6 months',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Greyskull LP',
      'duration': '3-6 months',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Full Body 3x/Week',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Couch to 5K',
      'duration': '9 weeks',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'endurance',
      'type': 'cardio',
    },
    {
      'name': 'Bodyweight Fitness',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'endurance',
      'type': 'bodyweight',
    },
    {
      'name': 'Russian Squat Program',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'powerlifting',
    },
    {
      'name': 'Super Squats',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat'],
      'difficulty': 'advanced',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': '30-Day Squat Challenge',
      'duration': '30 days',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'bodyweight',
    },
    {
      'name': 'Bench Press Specialization',
      'duration': '3 weeks',
      'requires1RM': true,
      'lifts': ['Bench'],
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Deadlift Builder',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Arm Blaster',
      'duration': '4 weeks',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Shoulder Sculptor',
      'duration': '6 weeks',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
    {
      'name': 'Pull-Up Progression',
      'duration': '6 weeks',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'bodyweight',
    },
  ];

  // Default programs to use if fewer than 3 recommendations are available
  static const List<Map<String, dynamic>> defaultPrograms = [
    {
      'name': 'Starting Strength',
      'duration': '3-6 months',
      'requires1RM': false,
      'difficulty': 'beginner',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Madcow 5x5',
      'duration': '12-16 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift'],
      'difficulty': 'intermediate',
      'focus': 'strength',
      'type': 'strength',
    },
    {
      'name': 'Push/Pull/Legs (PPL)',
      'duration': 'Ongoing',
      'requires1RM': false,
      'difficulty': 'intermediate',
      'focus': 'muscle_gain',
      'type': 'strength',
    },
  ];

  Future<List<Map<String, dynamic>>> getRecommendedPrograms() async {
    // Fetch user preferences
    final fitnessGoal = await _settingsRepository.getFitnessGoal();
    final experienceLevel = await _settingsRepository.getExperienceLevel();
    final preferredWorkoutType = await _settingsRepository.getPreferredWorkoutType();

    print('User Preferences - Fitness Goal: $fitnessGoal, Experience Level: $experienceLevel, Preferred Workout Type: $preferredWorkoutType');

    // Fetch workout history to assess user activity
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final recentWorkouts = await _workoutRepository.getWorkoutsForWeek(startOfMonth, endOfMonth);
    final workoutFrequency = recentWorkouts.length / 4; // Approximate weekly frequency

    print('Workout History - Recent Workouts: ${recentWorkouts.length}, Workout Frequency: $workoutFrequency workouts/week');

    // Score programs based on user preferences and history
    final scoredPrograms = availablePrograms.map((program) {
      double score = 0.0;

      // Match fitness goal
      if (program['focus'] == fitnessGoal) {
        score += 3.0;
      } else if (fitnessGoal == 'weight_loss' && program['type'] == 'cardio') {
        score += 2.0;
      }

      // Match experience level
      if (program['difficulty'] == experienceLevel) {
        score += 2.0;
      } else if (experienceLevel == 'intermediate' && program['difficulty'] == 'beginner') {
        score += 1.0;
      } else if (experienceLevel == 'advanced' && program['difficulty'] == 'intermediate') {
        score += 1.0;
      }

      // Match preferred workout type
      if (program['type'] == preferredWorkoutType) {
        score += 2.0;
      }

      // Adjust based on workout frequency
      final durationWeeks = _parseDurationWeeks(program['duration']);
      if (workoutFrequency < 2 && durationWeeks > 12) {
        score -= 1.0; // Less frequent users might prefer shorter programs
      } else if (workoutFrequency > 4 && durationWeeks < 6) {
        score -= 1.0; // Frequent users might prefer longer programs
      }

      print('Scoring Program: ${program['name']}, Score: $score (Fitness Goal Match: ${program['focus'] == fitnessGoal}, Experience Level Match: ${program['difficulty'] == experienceLevel}, Workout Type Match: ${program['type'] == preferredWorkoutType})');

      return {
        'program': program,
        'score': score,
      };
    }).toList();

    // Sort by score and take top programs
    scoredPrograms.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    List<Map<String, dynamic>> recommended = scoredPrograms
        .map((entry) => entry['program'] as Map<String, dynamic>)
        .take(3)
        .toList();

    print('Initial Recommended Programs: ${recommended.map((p) => p['name']).toList()}');

    // If fewer than 3 programs are recommended, fill with default programs
    if (recommended.length < 3) {
      final remainingSlots = 3 - recommended.length;
      final usedProgramNames = recommended.map((p) => p['name'] as String).toSet();
      final additionalPrograms = defaultPrograms
          .where((program) => !usedProgramNames.contains(program['name']))
          .take(remainingSlots)
          .toList();
      recommended.addAll(additionalPrograms);
    }

    print('Final Recommended Programs: ${recommended.map((p) => p['name']).toList()}');

    return recommended;
  }

  // Helper method to parse duration into weeks
  int _parseDurationWeeks(String duration) {
    if (duration == 'Ongoing') return 52; // Assume a year for ongoing programs
    final match = RegExp(r'(\d+)(?:-(\d+))?').firstMatch(duration);
    if (match == null) return 0;
    final start = int.parse(match.group(1)!);
    final end = match.group(2) != null ? int.parse(match.group(2)!) : start;
    return (start + end) ~/ 2; // Average if a range, otherwise the single value
  }
}