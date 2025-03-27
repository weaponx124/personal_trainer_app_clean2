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
import 'dart:io' show Platform;
import 'package:personal_trainer_app_clean/core/services/database_service.dart';
import 'package:personal_trainer_app_clean/core/services/network_service.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_background.dart';

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
late Future<FlutterLocalNotificationsPlugin?> flutterLocalNotificationsPluginFuture;

Future<FlutterLocalNotificationsPlugin?> initializeNotifications() async {
  if (Platform.isWindows) {
    print('Main: Skipping notification initialization on Windows (unsupported platform).');
    return null;
  }

  print('Main: Initializing notifications...');
  final plugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  try {
    final initialized = await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Main: Received notification response: ${response.payload}');
        if (response.payload != null) {
          if (response.payload!.startsWith('workout_')) {
            final programId = response.payload!.split('_')[1];
            childScreenNotifier.value = ProgramDetailsScreen(programId: programId);
            selectedTabIndexNotifier.value = 1;
          } else if (response.payload!.startsWith('meal_')) {
            selectedTabIndexNotifier.value = 3;
          }
        }
      },
    );
    if (initialized == true) {
      print('Main: Notifications initialized successfully.');
    } else {
      print('Main: Failed to initialize notifications.');
      return null;
    }
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return plugin;
  } catch (e) {
    print('Main: Error initializing notifications: $e');
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  tz.initializeTimeZones();
  try {
    final localLocation = tz.getLocation('America/New_York');
    tz.setLocalLocation(localLocation);
    print('Main: Timezone set to ${localLocation.name}');
  } catch (e) {
    print('Main: Error setting timezone: $e');
    tz.setLocalLocation(tz.getLocation('UTC'));
    print('Main: Fallback to UTC timezone');
  }

  flutterLocalNotificationsPluginFuture = initializeNotifications();

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
                    scaffoldBackgroundColor: Colors.transparent, // Ensure theme doesn't override
                    colorScheme: AppTheme.lightTheme().colorScheme.copyWith(
                      secondary: accentColor,
                    ),
                  ),
                  darkTheme: AppTheme.darkTheme().copyWith(
                    scaffoldBackgroundColor: Colors.transparent, // Ensure theme doesn't override
                    colorScheme: AppTheme.darkTheme().colorScheme.copyWith(
                      secondary: accentColor,
                    ),
                  ),
                  themeMode: themeMode,
                  builder: (context, child) => AppBackground(child: child!),
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
                      print('Scriptures route args: $args');
                      scriptureArgsNotifier.value = args;
                      return const MainScreen(initialTab: 4);
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
  final GlobalKey<DietScreenState> _dietScreenKey = GlobalKey<DietScreenState>();
  final GlobalKey<ProgramDetailsScreenState> _programDetailsScreenKey = GlobalKey<ProgramDetailsScreenState>();

  @override
  void initState() {
    super.initState();
    print('MainScreen: Initializing MainScreen with initialTab: ${widget.initialTab}');
    _selectedIndex = widget.initialTab;
    selectedTabIndexNotifier.value = _selectedIndex;
    childScreenNotifier.value = widget.childScreen;
  }

  Future<void> _shareCurrentScreen() async {
    if (_selectedIndex == 3) {
      await _dietScreenKey.currentState?.shareDietSummary();
    } else if (childScreenNotifier.value is ProgramDetailsScreen) {
      await _programDetailsScreenKey.currentState?.shareProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('MainScreen: Building MainScreen...');
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return ValueListenableBuilder<Color>(
          valueListenable: accentColorNotifier,
          builder: (context, accentColor, child) {
            return ValueListenableBuilder<Widget?>(
              valueListenable: childScreenNotifier,
              builder: (context, childScreen, _) {
                print('MainScreen: Rendering with selectedIndex: $_selectedIndex');
                return Scaffold(
                  backgroundColor: Colors.transparent, // Ensure Scaffold is transparent
                  appBar: AppBar(
                    title: Text(
                      _selectedIndex == 0
                          ? 'Home'
                          : _selectedIndex == 1
                          ? 'Active Programs'
                          : _selectedIndex == 2
                          ? 'Progress'
                          : _selectedIndex == 3
                          ? 'Diet'
                          : _selectedIndex == 4
                          ? 'Scriptures'
                          : 'Workout Log',
                    ),
                    backgroundColor: Colors.transparent, // Make AppBar transparent
                    foregroundColor: const Color(0xFFB0B7BF),
                    elevation: 0, // Remove shadow to blend with background
                    actions: [
                      if (_selectedIndex == 3 || childScreenNotifier.value is ProgramDetailsScreen)
                        IconButton(
                          icon: const Icon(Icons.share, color: Color(0xFFB0B7BF)),
                          onPressed: _shareCurrentScreen,
                          tooltip: 'Share',
                        ),
                    ],
                  ),
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
                    selectedItemColor: accentColor,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                        selectedTabIndexNotifier.value = index;
                        childScreenNotifier.value = null;
                      });
                    },
                  ),
                );
              },
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
    DietScreen(key: _dietScreenKey),
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