import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/screens/splash_screen.dart';
import 'package:personal_trainer_app_clean/screens/home_screen.dart' as home;
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart' as programs;
import 'package:personal_trainer_app_clean/screens/progress_screen.dart' as progress;
import 'package:personal_trainer_app_clean/screens/diet_screen.dart' as diet;
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/screens/workout_screen.dart';

// Global unit state
ValueNotifier<String> unitNotifier = ValueNotifier('lbs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize();
  unitNotifier.value = await DatabaseHelper.getWeightUnit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Trainer',
      theme: ThemeData(
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.light(
          primary: Colors.blue[800]!,
          secondary: Colors.green[600]!,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[900]!,
          secondary: Colors.green[700]!,
          surface: Colors.grey[800]!,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/program_selection': (context) => programs.ProgramSelectionScreen(),
        '/program_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProgramDetailsScreen(
            programId: args['programId'] as String,
          );
        },
        '/settings': (context) => const SettingsScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/programs': (context) => ProgramsOverviewScreen(
          unit: unitNotifier.value,
          programName: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?)?['programName'] as String? ?? '',
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          body: SafeArea(child: _screens(unit)[_selectedIndex]),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Active Programs'), // Updated
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 8,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  static List<Widget> _screens(String unit) => <Widget>[
    home.HomeScreen(unit: unit),
    ProgramsOverviewScreen(unit: unit, programName: ''), // Replaced ProgramSelectionScreen
    progress.ProgressScreen(unit: unit),
    const diet.DietScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}