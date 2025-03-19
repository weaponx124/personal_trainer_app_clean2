import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyWeightProgressScreen extends StatefulWidget {
  final String unit;

  const BodyWeightProgressScreen({super.key, required this.unit});

  @override
  _BodyWeightProgressScreenState createState() => _BodyWeightProgressScreenState();
}

class _BodyWeightProgressScreenState extends State<BodyWeightProgressScreen> {
  List<Map<String, dynamic>> progress = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() => isLoading = true);
      progress = await DatabaseHelper.getProgress();
      setState(() => isLoading = false);
      print('Loaded progress in BodyWeightProgressScreen: $progress');
    } catch (e) {
      print('Error loading progress: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading progress: $e')));
    }
  }

  Future<void> _addProgress() async {
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Weight Progress'),
        content: TextField(
          controller: weightController,
          decoration: InputDecoration(
            labelText: 'Weight (${widget.unit})',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text) ?? 0.0;

              if (weight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid weight')),
                );
                return;
              }

              final newProgress = {
                'id': DateTime.now().toString(),
                'date': DateTime.now().toIso8601String(),
                'weight': weight,
              };
              await DatabaseHelper.insertProgress(newProgress);
              Navigator.pop(context);
              await _loadProgress();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProgress(String progressId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Progress Entry'),
        content: const Text('Are you sure you want to delete this progress entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.deleteProgress(progressId);
              Navigator.pop(context);
              await _loadProgress();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2526), // Matte Black
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
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB22222))) // Red
              : progress.isEmpty
              ? const Center(
            child: Text(
              'No progress entries yet. Tap the + button to add one.',
              style: TextStyle(fontSize: 16, color: Color(0xFF808080)), // Darker gray
            ),
          )
              : ListView.builder(
            itemCount: progress.length,
            itemBuilder: (context, index) {
              final entry = progress[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(context).colorScheme.surface, // Silver
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text(
                    (entry['date'] as String).split('T')[0],
                    style: const TextStyle(color: Color(0xFF1C2526)), // Matte Black
                  ),
                  subtitle: Text(
                    'Weight: ${(entry['weight'] as double?)?.toString() ?? 'N/A'} ${widget.unit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProgress(entry['id'] as String),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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