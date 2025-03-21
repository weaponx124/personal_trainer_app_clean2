import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';
import 'package:personal_trainer_app_clean/screens/body_weight_progress_screen.dart';
import 'package:personal_trainer_app_clean/screens/custom_program_form.dart';
import 'package:personal_trainer_app_clean/screens/home_screen.dart' as home;
import 'package:personal_trainer_app_clean/screens/profile_screen.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart' as programs;
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/screens/progress_screen.dart' as progress;
import 'package:personal_trainer_app_clean/features/diet/diet_screen.dart' as diet;
import 'package:personal_trainer_app_clean/screens/scripture_reading_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/screens/splash_screen.dart';
import 'package:personal_trainer_app_clean/screens/workout_screen.dart' as workout;
import 'package:personal_trainer_app_clean/screens/workout_log_screen.dart';

// Global unit state
ValueNotifier<String> unitNotifier = ValueNotifier<String>('lbs');
// Global theme state
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
// Global scripture arguments to persist across tab switches
ValueNotifier<Map<String, dynamic>?> scriptureArgsNotifier = ValueNotifier(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: unitNotifier,
          builder: (context, unit, child) {
            return MaterialApp(
              title: 'Seek & Lift',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeMode,
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/main': (context) => const MainScreen(),
                '/workout': (context) => workout.WorkoutScreen(),
                '/progress': (context) => progress.ProgressScreen(unit: unit),
                '/body_weight_progress': (context) => BodyWeightProgressScreen(unit: unit),
                '/profile': (context) => const ProfileScreen(),
                '/program_selection': (context) => programs.ProgramSelectionScreen(),
                '/program_details': (context) {
                  final String programId = ModalRoute.of(context)!.settings.arguments as String;
                  return ProgramDetailsScreen(programId: programId);
                },
                '/custom_program_form': (context) => const CustomProgramForm(),
                '/settings': (context) => const SettingsScreen(),
                '/scriptures': (context) {
                  final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
                  print('Scriptures route args: $args'); // Debug log
                  scriptureArgsNotifier.value = args; // Update global scripture args
                  return const MainScreen(initialTab: 4); // Redirect to MainScreen with Scriptures tab
                },
                '/diet': (context) => diet.DietScreen(),
                '/programs_overview': (context) => ProgramsOverviewScreen(unit: unit, programName: ''),
                '/workout_log': (context) => WorkoutLogScreen(unit: unit),
              },
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialTab;

  const MainScreen({super.key, this.initialTab = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

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
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Active Programs'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Scriptures'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Workout Log'),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  List<Widget> _screens(String unit) => <Widget>[
    home.HomeScreen(unit: unit),
    ProgramsOverviewScreen(unit: unit, programName: ''),
    progress.ProgressScreen(unit: unit),
    diet.DietScreen(),
    ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: scriptureArgsNotifier,
      builder: (context, args, child) {
        return ScriptureReadingScreen(
          book: args?['book'] as String?,
          chapter: args?['chapter'] as int?,
          verse: args?['verse'] as int?,
        );
      },
    ),
    WorkoutLogScreen(unit: unit),
  ];
}