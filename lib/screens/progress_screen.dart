import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_trainer_app_clean/core/data/models/progress.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/progress_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';

class ProgressScreen extends StatefulWidget {
  final String unit;

  const ProgressScreen({super.key, required this.unit});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  late Future<List<Progress>> _progressFuture;
  List<Progress> _progressData = [];
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
    _loadProgressData();
  }

  Future<List<Progress>> _loadProgress() async {
    try {
      final progress = await _progressRepository.getProgress();
      return progress;
    } catch (e) {
      print('Error loading progress: $e');
      AppSnackBar.showError(context, 'Failed to load progress: $e');
      return [];
    }
  }

  Future<void> _loadProgressData() async {
    final progress = await _progressFuture;
    setState(() {
      _progressData = List.from(progress);
    });
  }

  Future<void> _addProgressEntry() async {
    setState(() {
      _isAdding = true;
    });
    try {
      final now = DateTime.now();
      final newEntry = Progress(
        id: now.millisecondsSinceEpoch.toString(),
        weight: 70.0, // Placeholder; in a real app, this would come from user input
        date: now.millisecondsSinceEpoch,
      );
      await _progressRepository.insertProgress(newEntry);
      AppSnackBar.showSuccess(context, 'Progress entry added successfully!');
      setState(() {
        _progressFuture = _loadProgress();
        _loadProgressData();
      });
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to add progress entry: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress'),
            backgroundColor: const Color(0xFF1C2526),
            foregroundColor: const Color(0xFFB0B7BF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
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
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CrossPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                if (_isAdding)
                  const Center(child: LoadingIndicator())
                else
                  FutureBuilder<List<Progress>>(
                    future: _progressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No progress data available.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        );
                      }
                      final progressData = snapshot.data!;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                color: const Color(0xFFB0B7BF),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Weight Progress',
                                        style: GoogleFonts.oswald(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB22222),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 200,
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(show: false),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                  getTitlesWidget: (value, meta) {
                                                    return Text(
                                                      '${value.toInt()} ${widget.unit}',
                                                      style: GoogleFonts.roboto(
                                                        fontSize: 12,
                                                        color: const Color(0xFF808080),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                                    return SideTitleWidget(
                                                      axisSide: meta.axisSide,
                                                      child: Text(
                                                        '${date.month}/${date.day}',
                                                        style: GoogleFonts.roboto(
                                                          fontSize: 12,
                                                          color: const Color(0xFF808080),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: progressData
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final date = DateTime.fromMillisecondsSinceEpoch(entry.value.date);
                                                  return FlSpot(
                                                    date.millisecondsSinceEpoch.toDouble(),
                                                    entry.value.weight,
                                                  );
                                                })
                                                    .toList(),
                                                isCurved: true,
                                                color: const Color(0xFFB22222),
                                                barWidth: 2,
                                                dotData: FlDotData(show: true),
                                              ),
                                            ],
                                            lineTouchData: LineTouchData(
                                              touchTooltipData: LineTouchTooltipData(
                                                getTooltipColor: (_) => const Color(0xFFB0B7BF),
                                                getTooltipItems: (touchedSpots) {
                                                  return touchedSpots.map((spot) {
                                                    final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                                                    return LineTooltipItem(
                                                      '${date.month}/${date.day}: ${spot.y} ${widget.unit}',
                                                      GoogleFonts.roboto(
                                                        fontSize: 12,
                                                        color: const Color(0xFF1C2526),
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _addProgressEntry,
                                child: const Text('Add Progress Entry'),
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
            onPressed: () => Navigator.pushNamed(context, '/body_weight_progress'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}