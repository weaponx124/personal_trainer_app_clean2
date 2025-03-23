import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:personal_trainer_app_clean/screens/scripture_reading_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/screens/splash_screen.dart';
import 'package:personal_trainer_app_clean/screens/workout_screen.dart' as workout;
import 'package:personal_trainer_app_clean/screens/workout_log_screen.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Global unit state
ValueNotifier<String> unitNotifier = ValueNotifier<String>('lbs');
// Global theme state
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
// Global scripture arguments to persist across tab switches
ValueNotifier<Map<String, dynamic>?> scriptureArgsNotifier = ValueNotifier(null);
// Global selected tab index
ValueNotifier<int> selectedTabIndexNotifier = ValueNotifier<int>(0);
// Global child screen state
ValueNotifier<Widget?> childScreenNotifier = ValueNotifier<Widget?>(null);
// Global accent color state
ValueNotifier<Color> accentColorNotifier = ValueNotifier<Color>(const Color(0xFFB22222));
// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC')); // Set to UTC for simplicity; adjust as needed

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
            return ValueListenableBuilder<Color>(
              valueListenable: accentColorNotifier,
              builder: (context, accentColor, child) {
                return MaterialApp(
                  title: 'Seek & Lift',
                  theme: AppTheme.lightTheme().copyWith(
                    colorScheme: AppTheme.lightTheme().colorScheme.copyWith(
                      secondary: accentColor,
                    ),
                  ),
                  darkTheme: AppTheme.darkTheme().copyWith(
                    colorScheme: AppTheme.darkTheme().colorScheme.copyWith(
                      secondary: accentColor,
                    ),
                  ),
                  themeMode: themeMode,
                  initialRoute: '/splash',
                  routes: {
                    '/splash': (context) => const SplashScreen(),
                    '/main': (context) => const MainScreen(),
                    '/workout': (context) => const MainScreen(childScreen: workout.WorkoutScreen()),
                    '/body_weight_progress': (context) => const MainScreen(initialTab: 2, childScreen: BodyWeightProgressScreen()),
                    '/profile': (context) => const MainScreen(initialTab: 0, childScreen: ProfileScreen()),
                    '/program_selection': (context) => const MainScreen(initialTab: 1, childScreen: programs.ProgramSelectionScreen()),
                    '/program_details': (context) {
                      final String programId = ModalRoute.of(context)!.settings.arguments as String;
                      return MainScreen(initialTab: 1, childScreen: ProgramDetailsScreen(programId: programId));
                    },
                    '/custom_program_form': (context) => const MainScreen(initialTab: 1, childScreen: CustomProgramForm()),
                    '/settings': (context) => const MainScreen(initialTab: 0, childScreen: SettingsScreen()),
                    '/scriptures': (context) {
                      final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
                      print('Scriptures route args: $args'); // Debug log
                      scriptureArgsNotifier.value = args; // Update global scripture args
                      return const MainScreen(initialTab: 4); // Redirect to MainScreen with Scriptures tab
                    },
                    '/programs_overview': (context) => const MainScreen(initialTab: 1, childScreen: ProgramsOverviewScreen(programName: '')),
                    '/workout_log': (context) => const MainScreen(initialTab: 5),
                  },
                );
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
  final Widget? childScreen;

  const MainScreen({super.key, this.initialTab = 0, this.childScreen});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    selectedTabIndexNotifier.value = _selectedIndex;
    childScreenNotifier.value = widget.childScreen;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return ValueListenableBuilder<Widget?>(
          valueListenable: childScreenNotifier,
          builder: (context, childScreen, _) {
            return Scaffold(
              body: SafeArea(
                child: childScreen ?? _screens(unit)[_selectedIndex],
              ),
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
                    selectedTabIndexNotifier.value = index;
                    childScreenNotifier.value = null; // Clear child screen when switching tabs
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _screens(String unit) => <Widget>[
    home.HomeScreen(unit: unit),
    const ProgramsOverviewScreen(programName: ''),
    progress.ProgressScreen(),
    const DietScreen(),
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
    WorkoutLogScreen(),
  ];
}