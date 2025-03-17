import 'package:flutter/material.dart';
import '../database_helper.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<Map<String, dynamic>> meals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      setState(() => isLoading = true);
      meals = await DatabaseHelper.getMeals();
      setState(() => isLoading = false);
      print('Loaded meals: $meals');
    } catch (e) {
      print('Error loading meals: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading meals: $e')));
    }
  }

  Future<void> _addMeal() async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text) ?? 0;

              if (name.isEmpty || calories <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid meal name and calories')),
                );
                return;
              }

              final newMeal = {
                'id': DateTime.now().toString(),
                'name': name,
                'calories': calories,
              };
              await DatabaseHelper.insertMeal(newMeal);
              Navigator.pop(context);
              await _loadMeals();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMeal(String mealId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.deleteMeal(mealId);
              Navigator.pop(context);
              await _loadMeals();
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
        title: const Text('Diet'),
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('Back button pressed on DietScreen, popping route');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMeal,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : meals.isEmpty
          ? const Center(child: Text('No meals yet. Tap the + button to add one.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(meal['name'] as String),
              subtitle: Text('Calories: ${meal['calories'] ?? 'N/A'}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteMeal(meal['id'] as String),
              ),
            ),
          );
        },
      ),
    );
  }
}