import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/screens/program_actions.dart';
import 'package:personal_trainer_app_clean/screens/program_list_builder.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:animate_do/animate_do.dart';

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

  double calculateProgress(Map<String, dynamic> program) {
    int sessionsCompleted = program['sessionsCompleted'] as int? ?? 0;
    int totalSessions = program['totalSessions'] as int? ?? 1;
    return totalSessions > 0 ? sessionsCompleted / totalSessions : 0.0;
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
            title: const Text('Active Programs'),
            backgroundColor: const Color(0xFF1C2526),
            foregroundColor: const Color(0xFFB0B7BF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                print('Back button pressed on ProgramsOverviewScreen, popping route');
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
              ),
            ),
            child: Stack(
              children: [
                // Subtle Cross Background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CrossPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                FutureBuilder<void>(
                  future: _fetchProgramsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('FutureBuilder waiting for _fetchProgramsFuture to complete');
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
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
                              icon: const Icon(Icons.add),
                              label: const Text('Add New Program'),
                              onPressed: () {
                                print('Navigating to ProgramSelectionScreen to add a new program');
                                Navigator.pushNamed(context, '/program_selection');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB22222),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              progressCalculator: calculateProgress,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/program_selection');
            },
            backgroundColor: const Color(0xFFB22222),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// Custom painter for cross background
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB) // Soft Sky Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double crossSize = 100.0;
    for (double x = 0; x < size.width; x += crossSize * 1.5) {
      for (double y = 0; y < size.height; y += crossSize * 1.5) {
        canvas.drawLine(
          Offset(x + crossSize / 2, y),
          Offset(x + crossSize / 2, y + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(x + crossSize / 4, y + crossSize / 2),
          Offset(x + 3 * crossSize / 4, y + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}