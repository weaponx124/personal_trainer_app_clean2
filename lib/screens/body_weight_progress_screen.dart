import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_trainer_app_clean/core/data/models/progress.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/progress_repository.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';

class BodyWeightProgressScreen extends StatefulWidget {
  final String unit;

  const BodyWeightProgressScreen({super.key, required this.unit});

  @override
  _BodyWeightProgressScreenState createState() => _BodyWeightProgressScreenState();
}

class _BodyWeightProgressScreenState extends State<BodyWeightProgressScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  late Future<List<Progress>> _progressFuture;
  List<Progress> _progress = [];
  double _maxWeight = 0.0;
  double _minWeight = double.infinity;
  double _totalChange = 0.0;
  int _entryCount = 0;

  @override
  void initState() {
    super.initState();
    _progressFuture = _progressRepository.getProgress();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progressFuture;
    setState(() {
      _progress = List.from(progress);
      _updateStats();
    });
  }

  void _updateStats() {
    if (_progress.isEmpty) {
      _maxWeight = 0.0;
      _minWeight = 0.0;
      _totalChange = 0.0;
      _entryCount = 0;
      return;
    }

    _entryCount = _progress.length;
    _maxWeight = _progress
        .map((p) => p.weight)
        .reduce((a, b) => a > b ? a : b);
    _minWeight = _progress
        .map((p) => p.weight)
        .reduce((a, b) => a < b ? a : b);
    if (_progress.length >= 2) {
      final firstWeight = _progress.first.weight;
      final lastWeight = _progress.last.weight;
      _totalChange = lastWeight - firstWeight;
    } else {
      _totalChange = 0.0;
    }
  }

  List<FlSpot> _getSpots() {
    if (_progress.isEmpty) return [];

    _progress.sort((a, b) => a.date.compareTo(b.date));

    return _progress.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weight = entry.value.weight;
      return FlSpot(index, weight);
    }).toList();
  }

  Future<void> _addProgressEntry() async {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController bodyFatController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Progress Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (${widget.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyFatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Body Fat (%)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid weight')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final progressEntry = Progress(
        id: '',
        date: DateTime.now().millisecondsSinceEpoch,
        weight: double.tryParse(weightController.text) ?? 0.0,
        bodyFat: double.tryParse(bodyFatController.text),
        measurements: null,
      );
      await _progressRepository.insertProgress(progressEntry);
      setState(() {
        _progressFuture = _progressRepository.getProgress();
        _loadProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
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
                            'Progress Statistics',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Entries: $_entryCount',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Max Weight: ${_maxWeight.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Min Weight: ${_minWeight == double.infinity ? 0.0 : _minWeight.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Total Change: ${_totalChange.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Progress>>(
                      future: _progressFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
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
                        final spots = _getSpots();
                        if (spots.isEmpty) {
                          return Center(
                            child: Text(
                              'No progress data to display.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                          );
                        }
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: const Color(0xFFB0B7BF),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight Over Time',
                                  style: GoogleFonts.oswald(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB22222),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: GoogleFonts.roboto(
                                                  fontSize: 12,
                                                  color: const Color(0xFF808080),
                                                ),
                                              );
                                            },
                                          ),
                                          axisNameWidget: Text(
                                            'Weight (${widget.unit})',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF1C2526),
                                            ),
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '',
                                              );
                                            },
                                          ),
                                          axisNameWidget: Text(
                                            'Progress Over Time',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF1C2526),
                                            ),
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spots,
                                          isCurved: true,
                                          color: const Color(0xFFB22222),
                                          barWidth: 3,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFFB22222).withOpacity(0.2),
                                          ),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProgressEntry,
        backgroundColor: const Color(0xFFB22222),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}