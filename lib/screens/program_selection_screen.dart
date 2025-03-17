import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'programs_overview_screen.dart';

class ProgramSelectionScreen extends StatefulWidget {
  final String unit;

  const ProgramSelectionScreen({super.key, required this.unit});

  @override
  _ProgramSelectionScreenState createState() => _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState extends State<ProgramSelectionScreen> {
  String selectedGoal = 'All'; // Default filter
  String selectedLevel = 'All'; // Default filter
  final List<Map<String, dynamic>> programs = [
    {
      'name': '5/3/1 Program',
      'category': 'Powerlifting',
      'level': 'Intermediate',
      'description': 'Build strength with a focus on squat, bench, deadlift, and overhead press.',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift', 'Overhead']
    },
    {
      'name': 'Texas Method',
      'category': 'Powerlifting',
      'level': 'Intermediate',
      'description': 'Weekly strength progression with volume, recovery, and intensity days.',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Madcow 5x5',
      'category': 'Powerlifting',
      'level': 'Intermediate',
      'description': 'Structured weekly progression for squat, bench, and deadlift.',
      'duration': '12-16 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Sheiko Beginner',
      'category': 'Powerlifting',
      'level': 'Beginner',
      'description': 'High-volume strength training for new powerlifters.',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Sheiko Intermediate',
      'category': 'Powerlifting',
      'level': 'Intermediate',
      'description': 'High-volume strength training for intermediate powerlifters.',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Sheiko Advanced',
      'category': 'Powerlifting',
      'level': 'Advanced',
      'description': 'High-volume strength training for advanced powerlifters.',
      'duration': '8-12 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Smolov Base Cycle',
      'category': 'Powerlifting',
      'level': 'Advanced',
      'description': 'Rapidly increase squat strength with high intensity.',
      'duration': '13 weeks',
      'requires1RM': true,
      'lifts': ['Squat']
    },
    {
      'name': 'Smolov Jr. (Bench)',
      'category': 'Powerlifting',
      'level': 'Advanced',
      'description': 'Rapidly increase bench press strength with high intensity.',
      'duration': '3-4 weeks',
      'requires1RM': true,
      'lifts': ['Bench']
    },
    {
      'name': 'Candito 6-Week Program',
      'category': 'Powerlifting',
      'level': 'Intermediate',
      'description': 'Build strength with phases for hypertrophy and peaking.',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Push/Pull/Legs (PPL)',
      'category': 'Bodybuilding',
      'level': 'All',
      'description': 'Build muscle with a 6-day split focusing on push, pull, and legs.',
      'duration': 'Ongoing',
      'requires1RM': false
    },
    {
      'name': 'Arnold Split',
      'category': 'Bodybuilding',
      'level': 'Intermediate',
      'description': 'Maximize hypertrophy with a high-volume 6-day split.',
      'duration': 'Ongoing',
      'requires1RM': false
    },
    {
      'name': 'Bro Split',
      'category': 'Bodybuilding',
      'level': 'Beginner',
      'description': 'Target one muscle group per day for maximum growth.',
      'duration': 'Ongoing',
      'requires1RM': false
    },
    {
      'name': 'PHUL',
      'category': 'Bodybuilding',
      'level': 'Intermediate',
      'description': 'Combine strength and hypertrophy with an upper/lower split.',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'PHAT',
      'category': 'Bodybuilding',
      'level': 'Advanced',
      'description': 'Blend powerlifting and bodybuilding for strength and size.',
      'duration': 'Ongoing',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'German Volume Training',
      'category': 'Bodybuilding',
      'level': 'Intermediate',
      'description': 'Rapid muscle growth through extreme volume (10x10).',
      'duration': '4-6 weeks',
      'requires1RM': true,
      'lifts': ['Squat', 'Bench', 'Deadlift']
    },
    {
      'name': 'Starting Strength',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Build foundational strength with linear progression.',
      'duration': '3-6 months',
      'requires1RM': false
    },
    {
      'name': 'StrongLifts 5x5',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Build strength and muscle with a simple 5x5 program.',
      'duration': '3-6 months',
      'requires1RM': false
    },
    {
      'name': 'Greyskull LP',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Build strength with a focus on upper body frequency.',
      'duration': '3-6 months',
      'requires1RM': false
    },
    {
      'name': 'Full Body 3x/Week',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Improve overall fitness with compound lifts and accessories.',
      'duration': 'Ongoing',
      'requires1RM': false
    },
    {
      'name': 'Couch to 5K',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Build running endurance to run 5K in 9 weeks.',
      'duration': '9 weeks',
      'requires1RM': false
    },
    {
      'name': 'Bodyweight Fitness',
      'category': 'General Fitness',
      'level': 'Beginner',
      'description': 'Build strength using bodyweight exercises.',
      'duration': 'Ongoing',
      'requires1RM': false
    },
    {
      'name': 'Russian Squat Program',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Increase squat strength rapidly with high frequency.',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat']
    },
    {
      'name': 'Super Squats',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Build leg size and strength with 20-rep squats.',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Squat']
    },
    {
      'name': '30-Day Squat Challenge',
      'category': 'Specific Body Part',
      'level': 'Beginner',
      'description': 'Improve squat endurance with bodyweight squats.',
      'duration': '30 days',
      'requires1RM': false
    },
    {
      'name': 'Bench Press Specialization',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Increase bench press strength with high frequency.',
      'duration': '3 weeks',
      'requires1RM': true,
      'lifts': ['Bench']
    },
    {
      'name': 'Deadlift Builder',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Improve deadlift strength with deficit deadlifts.',
      'duration': '6 weeks',
      'requires1RM': true,
      'lifts': ['Deadlift']
    },
    {
      'name': 'Arm Blaster',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Build bigger biceps and triceps with high volume.',
      'duration': '4 weeks',
      'requires1RM': false
    },
    {
      'name': 'Shoulder Sculptor',
      'category': 'Specific Body Part',
      'level': 'Intermediate',
      'description': 'Build wider, stronger shoulders with focused training.',
      'duration': '6 weeks',
      'requires1RM': false
    },
    {
      'name': 'Pull-Up Progression',
      'category': 'Specific Body Part',
      'level': 'Beginner',
      'description': 'Achieve or increase pull-up reps with progressions.',
      'duration': '6 weeks',
      'requires1RM': false
    },
  ];

  void _startProgram(String programName, bool requires1RM, List<String>? lifts) {
    print('Starting program: $programName, requires1RM: $requires1RM, lifts: $lifts');
    if (requires1RM) {
      print('Navigating to ProgramsOverviewScreen for 1RM input');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProgramsOverviewScreen(
            unit: widget.unit,
            initialProgram: {'name': programName, 'requires1RM': requires1RM, 'lifts': lifts},
          ),
        ),
      );
    } else {
      print('Saving program $programName directly');
      DatabaseHelper.saveProgram(programName, {'unit': widget.unit}).then((_) {
        print('Program saved, navigating to ProgramsOverviewScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramsOverviewScreen(unit: widget.unit),
          ),
        );
      }).catchError((e) {
        print('Error saving program: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrograms = programs.where((program) {
      bool matchesGoal = selectedGoal == 'All' || program['category'] == selectedGoal;
      bool matchesLevel = selectedLevel == 'All' || program['level'] == selectedLevel;
      return matchesGoal && matchesLevel;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Program'),
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('Back button pressed on ProgramSelectionScreen, popping route');
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter by Goal
            const Text('Filter by Goal:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                _buildFilterChip('All', selectedGoal, (value) => setState(() => selectedGoal = value)),
                _buildFilterChip('Powerlifting', selectedGoal, (value) => setState(() => selectedGoal = value)),
                _buildFilterChip('Bodybuilding', selectedGoal, (value) => setState(() => selectedGoal = value)),
                _buildFilterChip('General Fitness', selectedGoal, (value) => setState(() => selectedGoal = value)),
                _buildFilterChip('Specific Body Part', selectedGoal, (value) => setState(() => selectedGoal = value)),
              ],
            ),
            const SizedBox(height: 16),
            // Filter by Experience Level
            const Text('Filter by Level:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                _buildFilterChip('All', selectedLevel, (value) => setState(() => selectedLevel = value)),
                _buildFilterChip('Beginner', selectedLevel, (value) => setState(() => selectedLevel = value)),
                _buildFilterChip('Intermediate', selectedLevel, (value) => setState(() => selectedLevel = value)),
                _buildFilterChip('Advanced', selectedLevel, (value) => setState(() => selectedLevel = value)),
              ],
            ),
            const SizedBox(height: 16),
            // Program List
            Expanded(
              child: ListView.builder(
                itemCount: filteredPrograms.length,
                itemBuilder: (context, index) {
                  final program = filteredPrograms[index];
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.orange[50],
                    child: ListTile(
                      leading: Icon(
                        program['category'] == 'Powerlifting'
                            ? Icons.fitness_center
                            : program['category'] == 'Bodybuilding'
                            ? Icons.directions_run
                            : program['category'] == 'General Fitness'
                            ? Icons.health_and_safety
                            : Icons.bolt,
                        color: Colors.orange,
                      ),
                      title: Text(
                        program['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goal: ${program['category']}', style: const TextStyle(fontSize: 12)),
                          Text('Level: ${program['level']}', style: const TextStyle(fontSize: 12)),
                          Text('Duration: ${program['duration']}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(program['description'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      onTap: () {
                        print('Tapped on program: ${program['name']}');
                        _startProgram(
                          program['name'],
                          program['requires1RM'] ?? false,
                          program['lifts']?.cast<String>(),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, Function(String) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == label,
      onSelected: (selected) {
        if (selected) {
          onSelected(label);
        }
      },
      selectedColor: Colors.orange[700],
      labelStyle: TextStyle(
        color: selectedValue == label ? Colors.white : Colors.black,
      ),
    );
  }
}