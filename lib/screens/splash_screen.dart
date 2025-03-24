import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/services/notification_service.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';
import 'dart:io' show Platform;
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    try {
      print('SplashScreen: Starting navigation to home...');
      await Future.delayed(const Duration(seconds: 3));
      print('SplashScreen: Delay completed.');

      // Migrate data from SharedPreferences to SQLite
      print('SplashScreen: Migrating data to SQLite...');
      final programRepository = getIt<ProgramRepository>();
      final workoutRepository = getIt<WorkoutRepository>();
      final mealRepository = getIt<MealRepository>();

      await programRepository.migrateFromSharedPreferences();
      print('SplashScreen: Program data migration completed.');
      await workoutRepository.migrateFromSharedPreferences();
      print('SplashScreen: Workout data migration completed.');
      await mealRepository.migrateFromSharedPreferences();
      print('SplashScreen: Meal data migration completed.');

      // Wait for the notification plugin to be initialized
      print('SplashScreen: Waiting for notification plugin initialization...');
      final notificationPlugin = await flutterLocalNotificationsPluginFuture;
      print('SplashScreen: Notification plugin initialized: ${notificationPlugin != null}');

      // Schedule notifications only if the plugin is available (not on Windows)
      if (notificationPlugin != null) {
        final notificationService = NotificationService(notificationPlugin);
        print('SplashScreen: Scheduling workout notifications...');
        await notificationService.scheduleWorkoutNotifications();
        print('SplashScreen: Workout notifications scheduled.');
        print('SplashScreen: Scheduling meal notifications...');
        await notificationService.scheduleMealNotifications();
        print('SplashScreen: Meal notifications scheduled.');
        print('SplashScreen: Scheduling water notifications...');
        await notificationService.scheduleWaterNotifications();
        print('SplashScreen: Water notifications scheduled.');
      } else {
        print('SplashScreen: Skipping notification scheduling on unsupported platform (e.g., Windows).');
      }

      // Navigate to MainScreen using MaterialApp's routing
      print('SplashScreen: Navigating to MainScreen...');
      await Navigator.pushReplacementNamed(context, '/main');
      print('SplashScreen: Navigation triggered.');
    } catch (e, stackTrace) {
      print('SplashScreen: Error during navigation: $e');
      print('Stack trace: $stackTrace');
      // Fallback navigation in case of error
      await Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SplashScreen: Building splash screen...');
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue.withOpacity(0.4), // Brighter starting color
              AppTheme.matteBlack.withOpacity(0.8), // Slightly lighter matte black
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/logo_512_transparent.png',
            height: 250, // Increased logo size
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}