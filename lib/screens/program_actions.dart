import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:uuid/uuid.dart';

class ProgramActions extends StatefulWidget {
  final String programName;
  final List<String> lifts;
  final String unit;

  const ProgramActions({
    super.key,
    required this.programName,
    required this.lifts,
    required this.unit,
  });

  @override
  _ProgramActionsState createState() => _ProgramActionsState();
}

class _ProgramActionsState extends State<ProgramActions> {
  final ProgramRepository _programRepository = ProgramRepository();
  Map<String, TextEditingController> _oneRMControllers = {};
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    for (var lift in widget.lifts) {
      _oneRMControllers[lift] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _oneRMControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _startProgram() async {
    setState(() {
      _isStarting = true;
    });

    try {
      final programId = Uuid().v4();
      final startDate = DateTime.now().toIso8601String().split('T')[0];
      Map<String, dynamic> oneRMs = {};
      Map<String, dynamic> details = {
        'unit': widget.unit,
      };

      for (var lift in widget.lifts) {
        final controller = _oneRMControllers[lift];
        oneRMs[lift] = double.tryParse(controller?.text ?? '0') ?? 0.0;
      }
      details['original1RMs'] = Map<String, double>.from(oneRMs);
      details['originalUnit'] = widget.unit;

      final newProgram = Program(
        id: programId,
        name: widget.programName,
        description: 'Custom Program',
        oneRMs: oneRMs,
        details: details,
        completed: false,
        startDate: startDate,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
      );

      await _programRepository.insertProgram(newProgram);
      AppSnackBar.showSuccess(context, 'Program started successfully!');
      Navigator.pushNamed(context, '/main', arguments: 1);
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to start program: $e');
    } finally {
      setState(() {
        _isStarting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start ${widget.programName}'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
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
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: CrossPainter(),
                  child: Container(),
                ),
              ),
            ),
            if (_isStarting)
              const Center(child: LoadingIndicator())
            else
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter your 1RMs (${widget.unit}):',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB22222),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.lifts.map((lift) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: _oneRMControllers[lift],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '$lift 1RM',
                              labelStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFB0B7BF),
                            ),
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startProgram,
                        child: const Text('Start Program'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}