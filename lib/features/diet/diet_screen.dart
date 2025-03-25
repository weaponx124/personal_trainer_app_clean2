import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _logic = DietScreenLogic(this);
    _logic.init();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Diet Profile'),
        content: SizedBox(
          height: 200,
          width: 280,
          child: ListView.builder(
            itemCount: DietProfile.profiles.length,
            itemBuilder: (context, index) {
              final profile = DietProfile.profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('P: ${profile.proteinGrams.toStringAsFixed(0)}g, C: ${profile.carbsGrams.toStringAsFixed(0)}g, F: ${profile.fatGrams.toStringAsFixed(0)}g'),
                onTap: () {
                  _logic.setDietProfile(profile);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            icon: const Icon(Icons.settings),
            onPressed: _showProfileDialog,
            tooltip: 'Diet Profile',
          ),
        ],
      ),
      body: TabBarView(
        controller: _logic.tabController,
        children: [
          MealsTab(logic: _logic),
          RecipesTab(logic: _logic),
          ShoppingTab(logic: _logic),
        ],
      ),
      floatingActionButton: _logic.buildFAB(context),
    );
  }

  Future<void> shareDietSummary() async {
    print('Sharing diet summary...');
  }
}