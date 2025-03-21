import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
              theme: ThemeData(
                primaryColor: const Color(0xFF1C2526), // Matte Black
                scaffoldBackgroundColor: const Color(0xFF1C2526), // Matte Black
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF1C2526), // Matte Black
                  secondary: const Color(0xFFB22222), // Red
                  surface: const Color(0xFFB0B7BF), // Silver
                  onSurface: const Color(0xFF1C2526),
                ),
                textTheme: GoogleFonts.robotoTextTheme(
                  ThemeData.light().textTheme.copyWith(
                    headlineLarge: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB22222), // Red
                    ),
                    bodyMedium: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF808080), // Darker gray
                    ),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFB22222), // Red
                    foregroundColor: Colors.white,
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFFB0B7BF), // Silver
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: const Color(0xFFB22222), // Red
                  linearMinHeight: 8,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                primaryColor: const Color(0xFF1C2526), // Matte Black
                scaffoldBackgroundColor: const Color(0xFF1C2526), // Matte Black
                colorScheme: ColorScheme.dark(
                  primary: const Color(0xFF1C2526), // Matte Black
                  secondary: const Color(0xFFB22222), // Red
                  surface: const Color(0xFFB0B7BF), // Silver
                  onSurface: const Color(0xFF1C2526),
                ),
                textTheme: GoogleFonts.robotoTextTheme(
                  ThemeData.dark().textTheme.copyWith(
                    headlineLarge: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB22222), // Red
                    ),
                    bodyMedium: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF808080), // Darker gray
                    ),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFB22222), // Red
                    foregroundColor: Colors.white,
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFFB0B7BF), // Silver
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: const Color(0xFFB22222), // Red
                  linearMinHeight: 8,
                ),
                useMaterial3: true,
              ),
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
            selectedItemColor: Theme.of(context).colorScheme.secondary, // Red
            unselectedItemColor: const Color(0xFF808080), // Medium gray
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            elevation: 12,
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