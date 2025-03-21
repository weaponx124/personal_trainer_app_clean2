import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_trainer_app_clean/core/data/models/progress.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/progress_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';

class BodyWeightProgressScreen extends StatefulWidget {
  final String unit;

  const BodyWeightProgressScreen({super.key, required this.unit});

  @override
  _BodyWeightProgressScreenState createState() => _BodyWeightProgressScreenState();
}

class _BodyWeightProgressScreenState extends State<BodyWeightProgressScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  late Future<List<Progress>> _progressFuture;
  List<Progress> _progressData = [];
  final TextEditingController _weightController = TextEditingController();
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

  double get _maxWeight {
    if (_progressData.isEmpty) return 0.0;
    return _progressData
        .map((progress) => progress.weight) // weight is required in Progress
        .reduce((a, b) => a > b ? a : b);
  }

  double get _minWeight {
    if (_progressData.isEmpty) return 0.0;
    return _progressData
        .map((progress) => progress.weight) // weight is required in Progress
        .reduce((a, b) => a < b ? a : b);
  }

  Future<void> _addProgressEntry() async {
    if (_weightController.text.isEmpty) {
      AppSnackBar.showError(context, 'Please enter your weight');
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final now = DateTime.now();
      final newEntry = Progress(
        id: now.millisecondsSinceEpoch.toString(),
        weight: double.tryParse(_weightController.text) ?? 0.0,
        date: now.millisecondsSinceEpoch,
      );
      await _progressRepository.insertProgress(newEntry);
      AppSnackBar.showSuccess(context, 'Progress entry added successfully!');
      setState(() {
        _progressFuture = _loadProgress();
        _loadProgressData();
        _weightController.clear();
      });
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to add progress entry: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _deleteProgressEntry(String progressId) async {
    setState(() {
      _isAdding = true;
    });

    try {
      await _progressRepository.deleteProgress(progressId);
      AppSnackBar.showSuccess(context, 'Progress entry deleted successfully!');
      setState(() {
        _progressFuture = _loadProgress();
        _loadProgressData();
      });
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to delete progress entry: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Body Weight Progress'),
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
                if (_isAdding)
                  const Center(child: LoadingIndicator())
                else
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: const Color(0xFFB0B7BF),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Body Weight Progress',
                                    style: GoogleFonts.oswald(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFB22222),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: FutureBuilder<List<Progress>>(
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
                                                fontSize: 14,
                                                color: const Color(0xFF808080),
                                              ),
                                            ),
                                          );
                                        }
                                        final progressData = snapshot.data!;
                                        return LineChart(
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
                                            minY: _minWeight - 5,
                                            maxY: _maxWeight + 5,
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: progressData
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final progress = entry.value;
                                                  final date = DateTime.fromMillisecondsSinceEpoch(progress.date);
                                                  return FlSpot(
                                                    date.millisecondsSinceEpoch.toDouble(),
                                                    progress.weight,
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Weight (${widget.unit})',
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addProgressEntry,
                            child: const Text('Add Weight Entry'),
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<List<Progress>>(
                            future: _progressFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final progressData = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: progressData.length,
                                itemBuilder: (context, index) {
                                  final progress = progressData[index];
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: const Color(0xFFB0B7BF),
                                    child: ListTile(
                                      title: Text(
                                        '${progress.weight} ${widget.unit}',
                                        style: GoogleFonts.oswald(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB22222),
                                        ),
                                      ),
                                      subtitle: Text(
                                        DateTime.fromMillisecondsSinceEpoch(progress.date).toString(),
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                                        onPressed: () => _deleteProgressEntry(progress.id),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}