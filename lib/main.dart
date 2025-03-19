import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/screens/splash_screen.dart';
import 'package:personal_trainer_app_clean/screens/home_screen.dart' as home;
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart' as programs;
import 'package:personal_trainer_app_clean/screens/progress_screen.dart' as progress;
import 'package:personal_trainer_app_clean/screens/diet_screen.dart' as diet;
import 'package:personal_trainer_app_clean/screens/workout_screen.dart' as workout;
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/screens/scripture_reading_screen.dart';

// Global unit state
ValueNotifier<String> unitNotifier = ValueNotifier('lbs');
// Global theme state
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize();
  unitNotifier.value = await DatabaseHelper.getWeightUnit();
  themeNotifier.value = await DatabaseHelper.getThemeMode();
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
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Seek & Lift',
          theme: ThemeData(
            primaryColor: const Color(0xFF1C2526), // Matte Black
            scaffoldBackgroundColor: const Color(0xFF1C2526), // Matte Black
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1C2526), // Matte Black
              secondary: const Color(0xFFB22222), // Red
              surface: const Color(0xFFB0B7BF), // Silver
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
            '/workout': (context) => workout.WorkoutScreen(),
            '/programs': (context) => ProgramsOverviewScreen(
              unit: unitNotifier.value,
              programName: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?)?['programName'] as String? ?? '',
            ),
            '/scriptures': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              print('Scriptures route args: $args'); // Debug log
              return ScriptureReadingScreen(
                book: args?['book'] as String?,
                chapter: args?['chapter'] as int?,
                verse: args?['verse'] as int?,
              );
            },
          },
        );
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
  void initState() {
    super.initState();
    // Ensure Home tab is selected when navigated to
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.name == '/main') {
        setState(() {
          _selectedIndex = 0; // Force Home tab
        });
      }
    });
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
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary, // Red
            unselectedItemColor: const Color(0xFF808080), // Medium gray
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            elevation: 12,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 4) { // Scriptures tab
                  // Navigate with the last known arguments (if any)
                  Navigator.pushNamed(context, '/scriptures');
                }
              });
            },
          ),
        );
      },
    );
  }

  static List<Widget> _screens(String unit) => <Widget>[
    home.HomeScreen(unit: unit),
    ProgramsOverviewScreen(unit: unit, programName: ''),
    progress.ProgressScreen(unit: unit),
    diet.DietScreen(),
    const ScriptureReadingScreen(), // Default instance for nav bar
  ];
}