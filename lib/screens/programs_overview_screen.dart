import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'program_actions.dart';
import 'program_list_builder.dart';

class ProgramsOverviewScreen extends StatefulWidget {
  final String unit;
  final Map<String, dynamic>? initialProgram; // Parameter to handle program selection from ProgramSelectionScreen

  const ProgramsOverviewScreen({super.key, required this.unit, this.initialProgram});

  @override
  _ProgramsOverviewScreenState createState() => _ProgramsOverviewScreenState();
}

class _ProgramsOverviewScreenState extends State<ProgramsOverviewScreen> {
  List<Map<String, dynamic>> programs = [];
  bool isLoading = true;
  late Future<void> _fetchProgramsFuture; // Store the future to prevent infinite loop

  @override
  void initState() {
    super.initState();
    print('ProgramsOverviewScreen initState with unit: ${widget.unit}, initialProgram: ${widget.initialProgram}');
    // Handle initial program selection if provided, with a slight delay to ensure widget is ready
    if (widget.initialProgram != null) {
      print('Processing initial program: ${widget.initialProgram!['name']}');
      Future.microtask(() {
        if (mounted) {
          startProgram(
            context,
            widget.initialProgram!['name'],
            true,
            null,
            widget.initialProgram!['requires1RM'] ?? false,
            widget.initialProgram!['lifts']?.cast<String>(),
            _refreshPrograms, // Pass the refresh callback directly
            widget.unit,
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ProgramsOverviewScreen didChangeDependencies with unit: ${widget.unit}, setting up fetch');
    _fetchProgramsFuture = _loadPrograms(); // Initialize or update the future
  }

  @override
  void didUpdateWidget(ProgramsOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit) {
      print('Unit changed from ${oldWidget.unit} to ${widget.unit}, updating fetch');
      _fetchProgramsFuture = _loadPrograms(); // Update future when unit changes
    }
  }

  Future<void> _loadPrograms() async {
    try {
      print('Loading programs for unit: ${widget.unit} - Starting fetch');
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
    // Perform the asynchronous work outside of setState
    await _loadPrograms();
    // No need to update _fetchProgramsFuture here since _loadPrograms already updates the state
    print('Programs refreshed after async operation');
  }

  @override
  Widget build(BuildContext context) {
    print('ProgramsOverviewScreen build with unit: ${widget.unit}, programs: $programs');
    final currentPrograms = programs.where((p) => p['completed'] != true).toList();
    final completedPrograms = programs.where((p) => p['completed'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
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
                      Navigator.pushNamed(
                        context,
                        '/program_selection',
                        arguments: {'unit': widget.unit},
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add New Program', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildProgramList(
                    context: context,
                    currentPrograms: currentPrograms,
                    completedPrograms: completedPrograms,
                    unit: widget.unit,
                    startProgram: startProgram,
                    editProgram: editProgram,
                    deleteProgram: deleteProgram,
                    refreshPrograms: _refreshPrograms, // Pass the updated refresh callback
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}