import 'package:flutter/material.dart';
import 'program_details_screen.dart';
import '../database_helper.dart';

class ProgramsOverviewScreen extends StatelessWidget {
  final String programName;
  final String unit;

  const ProgramsOverviewScreen({super.key, required this.programName, required this.unit});

  Future<List<Map<String, dynamic>>> _getPrograms() async {
    final dbHelper = DatabaseHelper();
    // Placeholder: Replace with actual DB call if available
    return [
      {'id': 1, 'name': 'Starting Strength', 'description': 'Beginner strength'},
      {'id': 2, 'name': '5/3/1', 'description': 'Progressive overload'},
      {'id': 3, 'name': 'PPL', 'description': 'Push/Pull/Legs'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$programName Overview',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getPrograms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No programs available'));
                }
                final programs = snapshot.data!;
                return ListView.builder(
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          programs[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(programs[index]['description']),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProgramDetailsScreen(
                                programId: programs[index]['id'].toString(), // Convert int to String
                                unit: unit,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgramDetailsScreen(
                    programId: '1', // Placeholder ID as String
                    unit: unit,
                  ),
                ),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}