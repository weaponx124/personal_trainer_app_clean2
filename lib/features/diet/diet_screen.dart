import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './diet_screen_logic.dart';
import './meals_tab.dart';
import './recipes_tab.dart';
import './shopping_tab.dart';
import './diet_profile.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => DietScreenState();
}

class DietScreenState extends State<DietScreen> with SingleTickerProviderStateMixin {
  late DietScreenLogic _logic;
  bool _isLoading = true;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); // Added for SnackBar

  @override
  void initState() {
    super.initState();
    _logic = DietScreenLogic(this, _scaffoldMessengerKey); // Pass the GlobalKey to DietScreenLogic
    _initLogic();
  }

  Future<void> _initLogic() async {
    await _logic.init();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  void _showProfileDialog() {
    final caloriesController = TextEditingController(
      text: (_logic.customCalories ?? _logic.dietProfile.value.defaultCalories).toString(),
    );
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Diet Profile'),
          content: SizedBox(
            height: 400,
            width: 280,
            child: Column(
              children: [
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Daily Calories'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinController,
                        decoration: const InputDecoration(labelText: 'Protein %'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: carbsController,
                        decoration: const InputDecoration(labelText: 'Carbs %'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        decoration: const InputDecoration(labelText: 'Fat %'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: DietProfile.profiles.length + 1,
                    itemBuilder: (context, index) {
                      final calories = int.tryParse(caloriesController.text) ?? 2000;
                      if (index == 0) {
                        final protein = double.tryParse(proteinController.text) ?? 30.0;
                        final carbs = double.tryParse(carbsController.text) ?? 40.0;
                        final fat = double.tryParse(fatController.text) ?? 30.0;
                        final customProfile = DietProfile(
                          name: 'Custom',
                          proteinPercentage: protein,
                          carbsPercentage: carbs,
                          fatPercentage: fat,
                          defaultCalories: calories,
                          scripture: 'Proverbs 16:3 - "Commit to the Lord whatever you do, and he will establish your plans."',
                        );
                        return ListTile(
                          title: const Text('Custom'),
                          subtitle: Text(
                            'P: ${customProfile.proteinGrams(calories).toStringAsFixed(0)}g, C: ${customProfile.carbsGrams(calories).toStringAsFixed(0)}g, F: ${customProfile.fatGrams(calories).toStringAsFixed(0)}g',
                          ),
                          onTap: () {
                            _logic.setDietProfile(customProfile, calories);
                            Navigator.pop(context);
                          },
                        );
                      }
                      final profile = DietProfile.profiles[index - 1];
                      return ListTile(
                        title: Text(profile.name),
                        subtitle: Text(
                          'P: ${profile.proteinGrams(calories).toStringAsFixed(0)}g, C: ${profile.carbsGrams(calories).toStringAsFixed(0)}g, F: ${profile.fatGrams(calories).toStringAsFixed(0)}g',
                        ),
                        onTap: () {
                          _logic.setDietProfile(profile, calories);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealSetupDialog() {
    final countController = TextEditingController(text: _logic.mealNames.value.length.toString());
    final List<TextEditingController> nameControllers = _logic.mealNames.value
        .map((name) => TextEditingController(text: name))
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Up Meals'),
          content: SizedBox(
            height: 400,
            width: 280,
            child: Column(
              children: [
                TextField(
                  controller: countController,
                  decoration: const InputDecoration(labelText: 'Number of Meals'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 1;
                    while (nameControllers.length < count) {
                      nameControllers.add(TextEditingController(text: 'Meal ${nameControllers.length + 1}'));
                    }
                    while (nameControllers.length > count) {
                      nameControllers.removeLast();
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: nameControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: TextField(
                          controller: nameControllers[index],
                          decoration: InputDecoration(labelText: 'Meal ${index + 1} Name'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final names = nameControllers.map((c) => c.text).toList();
                _logic.setMealNames(names);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _logic.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _logic.selectedDate) {
      setState(() {
        _logic.setSelectedDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey, // Assign the GlobalKey to ScaffoldMessenger
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Diet'),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _showDatePicker,
                child: Text(
                  '${_logic.selectedDate.day}/${_logic.selectedDate.month}/${_logic.selectedDate.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _logic.tabController,
            tabs: const [
              Tab(text: 'Meals'),
              Tab(text: 'Recipes'),
              Tab(text: 'Shopping List'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.fastfood),
              onPressed: _showMealSetupDialog,
              tooltip: 'Set Up Meals',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showProfileDialog,
              tooltip: 'Diet Profile',
            ),
          ],
        ),
        body: TabBarView(
          controller: _logic.tabController,
          children: [
            Material(
              color: Colors.transparent,
              child: MealsTab(logic: _logic),
            ),
            Material(
              color: Colors.transparent,
              child: RecipesTab(logic: _logic),
            ),
            Material(
              color: Colors.transparent,
              child: ShoppingTab(logic: _logic),
            ),
          ],
        ),
        floatingActionButton: _logic.buildFAB(context),
      ),
    );
  }

  Future<void> shareDietSummary() async {
    print('Sharing diet summary...');
  }
}