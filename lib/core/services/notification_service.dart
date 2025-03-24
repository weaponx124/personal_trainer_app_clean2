import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'dart:io' show Platform;

class NotificationService {
  final FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  final SettingsRepository _settingsRepository;
  final ProgramRepository _programRepository;

  NotificationService(this._flutterLocalNotificationsPlugin)
      : _settingsRepository = SettingsRepository(),
        _programRepository = ProgramRepository();

  Future<void> scheduleWorkoutNotifications() async {
    if (_flutterLocalNotificationsPlugin == null || Platform.isWindows) {
      print('NotificationService: Skipping scheduleWorkoutNotifications on unsupported platform (e.g., Windows).');
      return;
    }

    try {
      print('NotificationService: Starting scheduleWorkoutNotifications...');
      // Cancel existing workout notifications
      await _flutterLocalNotificationsPlugin!.cancelAll();
      print('NotificationService: Canceled existing notifications.');

      final workoutReminderEnabled = await _settingsRepository.getWorkoutReminderEnabled();
      print('NotificationService: Workout reminder enabled: $workoutReminderEnabled');
      if (!workoutReminderEnabled) return;

      final programs = await _programRepository.getPrograms();
      print('NotificationService: Retrieved ${programs.length} programs.');
      final activePrograms = programs.where((p) => !p.completed).toList();
      print('NotificationService: Found ${activePrograms.length} active programs.');
      if (activePrograms.isEmpty) return;

      final workoutReminderTime = await _settingsRepository.getWorkoutReminderTime();
      print('NotificationService: Workout reminder time: ${workoutReminderTime.hour}:${workoutReminderTime.minute.toString().padLeft(2, '0')}');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var program in activePrograms) {
        // Schedule for the next 7 days
        for (int i = 0; i < 7; i++) {
          final workoutDate = today.add(Duration(days: i));
          final scheduledTime = tz.TZDateTime(
            tz.local,
            workoutDate.year,
            workoutDate.month,
            workoutDate.day,
            workoutReminderTime.hour,
            workoutReminderTime.minute,
          );

          if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

          print('NotificationService: Scheduling workout notification for ${program.name} on ${scheduledTime.toString()}');
          await _flutterLocalNotificationsPlugin!.zonedSchedule(
            program.id.hashCode + i, // Unique ID for each notification
            'Workout Reminder',
            'Time for your ${program.name} workout!',
            scheduledTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'workout_reminder_channel',
                'Workout Reminders',
                channelDescription: 'Notifications for workout reminders',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'workout_${program.id}',
          );
        }
      }
      print('NotificationService: Finished scheduling workout notifications.');
    } catch (e, stackTrace) {
      print('NotificationService: Error in scheduleWorkoutNotifications: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> scheduleMealNotifications() async {
    if (_flutterLocalNotificationsPlugin == null || Platform.isWindows) {
      print('NotificationService: Skipping scheduleMealNotifications on unsupported platform (e.g., Windows).');
      return;
    }

    try {
      print('NotificationService: Starting scheduleMealNotifications...');
      // Cancel existing meal notifications
      await _flutterLocalNotificationsPlugin!.cancelAll();
      print('NotificationService: Canceled existing notifications.');

      final mealReminderEnabled = await _settingsRepository.getMealReminderEnabled();
      print('NotificationService: Meal reminder enabled: $mealReminderEnabled');
      if (!mealReminderEnabled) return;

      final mealReminderTimes = await _settingsRepository.getMealReminderTimes();
      print('NotificationService: Meal reminder times: $mealReminderTimes');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var entry in mealReminderTimes.entries) {
        final mealType = entry.key;
        final time = entry.value;

        // Schedule for the next 7 days
        for (int i = 0; i < 7; i++) {
          final mealDate = today.add(Duration(days: i));
          final scheduledTime = tz.TZDateTime(
            tz.local,
            mealDate.year,
            mealDate.month,
            mealDate.day,
            time.hour,
            time.minute,
          );

          if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

          print('NotificationService: Scheduling meal notification for $mealType on ${scheduledTime.toString()}');
          await _flutterLocalNotificationsPlugin!.zonedSchedule(
            (mealType + i.toString()).hashCode, // Unique ID for each notification
            'Meal Reminder',
            'Time for your $mealType!',
            scheduledTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'meal_reminder_channel',
                'Meal Reminders',
                channelDescription: 'Notifications for meal logging reminders',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'meal_$mealType',
          );
        }
      }
      print('NotificationService: Finished scheduling meal notifications.');
    } catch (e, stackTrace) {
      print('NotificationService: Error in scheduleMealNotifications: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> scheduleWaterNotifications() async {
    if (_flutterLocalNotificationsPlugin == null || Platform.isWindows) {
      print('NotificationService: Skipping scheduleWaterNotifications on unsupported platform (e.g., Windows).');
      return;
    }

    try {
      print('NotificationService: Starting scheduleWaterNotifications...');
      // Cancel existing water notifications
      await _flutterLocalNotificationsPlugin!.cancelAll();
      print('NotificationService: Canceled existing notifications.');

      final waterReminderEnabled = await _settingsRepository.getWaterReminderEnabled();
      print('NotificationService: Water reminder enabled: $waterReminderEnabled');
      if (!waterReminderEnabled) return;

      final waterReminderTime = await _settingsRepository.getWaterReminderTime();
      print('NotificationService: Water reminder time: ${waterReminderTime.hour}:${waterReminderTime.minute.toString().padLeft(2, '0')}');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Schedule for the next 7 days
      for (int i = 0; i < 7; i++) {
        final waterDate = today.add(Duration(days: i));
        final scheduledTime = tz.TZDateTime(
          tz.local,
          waterDate.year,
          waterDate.month,
          waterDate.day,
          waterReminderTime.hour,
          waterReminderTime.minute,
        );

        if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        print('NotificationService: Scheduling water notification on ${scheduledTime.toString()}');
        await _flutterLocalNotificationsPlugin!.zonedSchedule(
          ('water' + i.toString()).hashCode, // Unique ID for each notification
          'Water Reminder',
          'Time to drink some water!',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'water_reminder_channel',
              'Water Reminders',
              channelDescription: 'Notifications for water intake reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'water',
        );
      }
      print('NotificationService: Finished scheduling water notifications.');
    } catch (e, stackTrace) {
      print('NotificationService: Error in scheduleWaterNotifications: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    if (_flutterLocalNotificationsPlugin == null || Platform.isWindows) {
      print('NotificationService: Skipping cancelAllNotifications on unsupported platform (e.g., Windows).');
      return;
    }

    try {
      print('NotificationService: Canceling all notifications...');
      await _flutterLocalNotificationsPlugin!.cancelAll();
      print('NotificationService: All notifications canceled.');
    } catch (e, stackTrace) {
      print('NotificationService: Error in cancelAllNotifications: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}