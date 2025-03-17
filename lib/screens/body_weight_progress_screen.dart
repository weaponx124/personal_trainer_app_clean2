import 'package:flutter/material.dart';
import '../database_helper.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Weight Progress'),
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('Back button pressed on BodyWeightProgressScreen, popping route');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProgress,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : progress.isEmpty
          ? const Center(child: Text('No progress entries yet. Tap the + button to add one.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        itemCount: progress.length,
        itemBuilder: (context, index) {
          final entry = progress[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text((entry['date'] as String).split('T')[0]),
              subtitle: Text('Weight: ${(entry['weight'] as double?)?.toString() ?? 'N/A'} ${widget.unit}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProgress(entry['id'] as String),
              ),
            ),
          );
        },
      ),
    );
  }
}