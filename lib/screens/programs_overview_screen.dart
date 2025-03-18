import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/screens/program_actions.dart';
import 'package:personal_trainer_app_clean/screens/program_list_builder.dart';
import 'package:personal_trainer_app_clean/main.dart'; // Correct import

class ProgramsOverviewScreen extends StatefulWidget {
  final String unit;
  final String programName;

  const ProgramsOverviewScreen({super.key, required this.unit, required this.programName});

  @override
  _ProgramsOverviewScreenState createState() => _ProgramsOverviewScreenState();
}

class _ProgramsOverviewScreenState extends State<ProgramsOverviewScreen> {
  List<Map<String, dynamic>> programs = [];
  bool isLoading = true;
  late Future<void> _fetchProgramsFuture;

  @override
  void initState() {
    super.initState();
    print('ProgramsOverviewScreen initState with unit: ${widget.unit}, programName: ${widget.programName}');
    _fetchProgramsFuture = _loadPrograms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ProgramsOverviewScreen didChangeDependencies with unit: ${widget.unit}, setting up fetch');
    _fetchProgramsFuture = _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      print('Loading programs for unit: ${unitNotifier.value} - Starting fetch');
      final loadedPrograms = await DatabaseHelper.getPrograms();
      print('Programs fetched: $loadedPrograms');
      if (mounted) {
        setState(() {
          programs = loadedPrograms;
          isLoading = false;
          print('Programs set in state: $programs');
        });
      }
    } catch (e) {
      print('Error loading programs: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading programs: $e')));
    }
  }

  void _refreshPrograms() async {
    await _loadPrograms();
    print('Programs refreshed after async operation');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        print('ProgramsOverviewScreen build with unit: $unit, programs: $programs');
        final currentPrograms = programs.where((p) => p['completed'] != true).toList();
        final completedPrograms = programs.where((p) => p['completed'] == true).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Programs'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                print('Back button pressed on ProgramsOverviewScreen, popping route');
                Navigator.pop(context);
              },
            ),
          ),
          body: FutureBuilder<void>(
            future: _fetchProgramsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('FutureBuilder waiting for _fetchProgramsFuture to complete');
                return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
              } else if (snapshot.hasError) {
                print('FutureBuilder error: ${snapshot.error}');
                return Center(child: Text('Error loading programs: ${snapshot.error}'));
              }
              print('FutureBuilder completed, building UI with programs: $programs');
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          print('Navigating to ProgramSelectionScreen to add a new program');
                          Navigator.pushNamed(context, '/program_selection');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Program'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildProgramList(
                        context: context,
                        currentPrograms: currentPrograms,
                        completedPrograms: completedPrograms,
                        unit: unit,
                        startProgram: startProgram,
                        editProgram: editProgram,
                        deleteProgram: deleteProgram,
                        refreshPrograms: _refreshPrograms,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}