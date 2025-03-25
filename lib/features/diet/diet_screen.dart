import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './meals_tab.dart';
import './recipes_tab.dart';
import './shopping_tab.dart';

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