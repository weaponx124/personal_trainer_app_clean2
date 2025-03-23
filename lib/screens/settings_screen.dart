import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/verse_of_the_day_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final VerseOfTheDayRepository _verseOfTheDayRepository = VerseOfTheDayRepository();
  String _weightUnit = 'lbs';
  ThemeMode _themeMode = ThemeMode.system;
  int _weeklyWorkoutGoal = 3;
  String _fitnessGoal = 'strength';
  String _experienceLevel = 'beginner';
  String _preferredWorkoutType = 'strength';
  Color _accentColor = const Color(0xFFB22222);
  final TextEditingController _goalController = TextEditingController();
  TimeOfDay _mealReminderTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _waterReminderTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _mealReminderEnabled = false;
  bool _waterReminderEnabled = false;
  bool _workoutReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final weightUnit = await _settingsRepository.getWeightUnit();
    final themeMode = await _settingsRepository.getThemeMode();
    final weeklyGoal = await _verseOfTheDayRepository.getWeeklyWorkoutGoal();
    final fitnessGoal = await _settingsRepository.getFitnessGoal();
    final experienceLevel = await _settingsRepository.getExperienceLevel();
    final preferredWorkoutType = await _settingsRepository.getPreferredWorkoutType();
    final savedAccentColor = prefs.getInt('accentColor');
    final mealReminderEnabled = prefs.getBool('mealReminderEnabled') ?? false;
    final waterReminderEnabled = prefs.getBool('waterReminderEnabled') ?? false;
    final workoutReminderEnabled = prefs.getBool('workoutReminderEnabled') ?? false;
    final mealReminderHour = prefs.getInt('mealReminderHour') ?? 12;
    final mealReminderMinute = prefs.getInt('mealReminderMinute') ?? 0;
    final waterReminderHour = prefs.getInt('waterReminderHour') ?? 10;
    final waterReminderMinute = prefs.getInt('waterReminderMinute') ?? 0;
    final workoutReminderHour = prefs.getInt('workoutReminderHour') ?? 18;
    final workoutReminderMinute = prefs.getInt('workoutReminderMinute') ?? 0;

    setState(() {
      _weightUnit = weightUnit;
      _themeMode = themeMode;
      _weeklyWorkoutGoal = weeklyGoal;
      _fitnessGoal = fitnessGoal;
      _experienceLevel = experienceLevel;
      _preferredWorkoutType = preferredWorkoutType;
      _accentColor = savedAccentColor != null ? Color(savedAccentColor) : const Color(0xFFB22222);
      _mealReminderEnabled = mealReminderEnabled;
      _waterReminderEnabled = waterReminderEnabled;
      _workoutReminderEnabled = workoutReminderEnabled;
      _mealReminderTime = TimeOfDay(hour: mealReminderHour, minute: mealReminderMinute);
      _waterReminderTime = TimeOfDay(hour: waterReminderHour, minute: waterReminderMinute);
      _workoutReminderTime = TimeOfDay(hour: workoutReminderHour, minute: workoutReminderMinute);
      _goalController.text = _weeklyWorkoutGoal.toString();
      unitNotifier.value = _weightUnit;
      themeModeNotifier.value = _themeMode;
      accentColorNotifier.value = _accentColor;
    });

    // Schedule notifications if enabled
    if (_mealReminderEnabled) _scheduleMealReminder();
    if (_waterReminderEnabled) _scheduleWaterReminder();
    if (_workoutReminderEnabled) _scheduleWorkoutReminder();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', _accentColor.value);
    await prefs.setBool('mealReminderEnabled', _mealReminderEnabled);
    await prefs.setBool('waterReminderEnabled', _waterReminderEnabled);
    await prefs.setBool('workoutReminderEnabled', _workoutReminderEnabled);
    await prefs.setInt('mealReminderHour', _mealReminderTime.hour);
    await prefs.setInt('mealReminderMinute', _mealReminderTime.minute);
    await prefs.setInt('waterReminderHour', _waterReminderTime.hour);
    await prefs.setInt('waterReminderMinute', _waterReminderTime.minute);
    await prefs.setInt('workoutReminderHour', _workoutReminderTime.hour);
    await prefs.setInt('workoutReminderMinute', _workoutReminderTime.minute);
  }

  Future<void> _pickAccentColor() async {
    final List<Color> colorOptions = [
      const Color(0xFFB22222),
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Accent Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: colorOptions.map((color) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                ),
                title: Text(
                  color == const Color(0xFFB22222)
                      ? 'Red (Default)'
                      : color == Colors.blue
                      ? 'Blue'
                      : color == Colors.green
                      ? 'Green'
                      : color == Colors.orange
                      ? 'Orange'
                      : color == Colors.purple
                      ? 'Purple'
                      : 'Teal',
                ),
                onTap: () => Navigator.pop(context, color),
              );
            }).toList(),
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

    if (selectedColor != null) {
      setState(() {
        _accentColor = selectedColor;
        accentColorNotifier.value = _accentColor;
        _saveSettings();
      });
    }
  }

  Future<void> _pickMealReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _mealReminderTime,
    );
    if (picked != null) {
      setState(() {
        _mealReminderTime = picked;
        _saveSettings();
        if (_mealReminderEnabled) _scheduleMealReminder();
      });
    }
  }

  Future<void> _pickWaterReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waterReminderTime,
    );
    if (picked != null) {
      setState(() {
        _waterReminderTime = picked;
        _saveSettings();
        if (_waterReminderEnabled) _scheduleWaterReminder();
      });
    }
  }

  Future<void> _pickWorkoutReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _workoutReminderTime,
    );
    if (picked != null) {
      setState(() {
        _workoutReminderTime = picked;
        _saveSettings();
        if (_workoutReminderEnabled) _scheduleWorkoutReminder();
      });
    }
  }

  Future<void> _scheduleMealReminder() async {
    await flutterLocalNotificationsPlugin.cancel(1); // Cancel existing meal reminder
    if (!_mealReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _mealReminderTime.hour,
      _mealReminderTime.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'meal_reminder_channel',
      'Meal Reminders',
      channelDescription: 'Notifications for meal logging reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Meal Reminder',
      'Time to log your meal!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the specified time
    );
  }

  Future<void> _scheduleWaterReminder() async {
    await flutterLocalNotificationsPlugin.cancel(2); // Cancel existing water reminder
    if (!_waterReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _waterReminderTime.hour,
      _waterReminderTime.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminders',
      channelDescription: 'Notifications for water intake reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'Water Reminder',
      'Time to drink some water!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the specified time
    );
  }

  Future<void> _scheduleWorkoutReminder() async {
    await flutterLocalNotificationsPlugin.cancel(3); // Cancel existing workout reminder
    if (!_workoutReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _workoutReminderTime.hour,
      _workoutReminderTime.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'workout_reminder_channel',
      'Workout Reminders',
      channelDescription: 'Notifications for workout reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      3,
      'Workout Reminder',
      'Time for your workout!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the specified time
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: CrossPainter(),
                    child: Container(),
                  ),
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Settings'),
                  backgroundColor: const Color(0xFF1C2526),
                  foregroundColor: const Color(0xFFB0B7BF),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
                    onPressed: () {
                      // Navigate back to main screen by clearing childScreenNotifier
                      childScreenNotifier.value = null;
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Units',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'lbs',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                value: 'lbs',
                                groupValue: _weightUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _weightUnit = value!;
                                    _settingsRepository.setWeightUnit(_weightUnit);
                                    unitNotifier.value = _weightUnit;
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(
                                  'kg',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                value: 'kg',
                                groupValue: _weightUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _weightUnit = value!;
                                    _settingsRepository.setWeightUnit(_weightUnit);
                                    unitNotifier.value = _weightUnit;
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Theme',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<ThemeMode>(
                                title: Text(
                                  'System',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                value: ThemeMode.system,
                                groupValue: _themeMode,
                                onChanged: (value) {
                                  setState(() {
                                    _themeMode = value!;
                                    _settingsRepository.setThemeMode(_themeMode);
                                    themeModeNotifier.value = _themeMode;
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<ThemeMode>(
                                title: Text(
                                  'Light',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                value: ThemeMode.light,
                                groupValue: _themeMode,
                                onChanged: (value) {
                                  setState(() {
                                    _themeMode = value!;
                                    _settingsRepository.setThemeMode(_themeMode);
                                    themeModeNotifier.value = _themeMode;
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<ThemeMode>(
                                title: Text(
                                  'Dark',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                value: ThemeMode.dark,
                                groupValue: _themeMode,
                                onChanged: (value) {
                                  setState(() {
                                    _themeMode = value!;
                                    _settingsRepository.setThemeMode(_themeMode);
                                    themeModeNotifier.value = _themeMode;
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Weekly Workout Goal',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Workouts per Week',
                            labelStyle: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF808080),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0B7BF),
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                          onChanged: (value) {
                            final goal = int.tryParse(value) ?? 3;
                            setState(() {
                              _weeklyWorkoutGoal = goal;
                            });
                            _verseOfTheDayRepository.setWeeklyWorkoutGoal(goal);
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Fitness Goal',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _fitnessGoal,
                          isExpanded: true,
                          items: ['strength', 'endurance', 'weight_loss', 'muscle_gain'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.replaceAll('_', ' ').capitalize(),
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _fitnessGoal = value;
                                _settingsRepository.setFitnessGoal(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Experience Level',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _experienceLevel,
                          isExpanded: true,
                          items: ['beginner', 'intermediate', 'advanced'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.capitalize(),
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _experienceLevel = value;
                                _settingsRepository.setExperienceLevel(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Preferred Workout Type',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _preferredWorkoutType,
                          isExpanded: true,
                          items: ['strength', 'cardio', 'bodyweight', 'powerlifting'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.capitalize(),
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _preferredWorkoutType = value;
                                _settingsRepository.setPreferredWorkoutType(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Accent Color',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _accentColor,
                          ),
                          title: Text(
                            'Select Accent Color',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          onTap: _pickAccentColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Reminders',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: Text(
                            'Meal Reminder',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          subtitle: Text(
                            'Time: ${_mealReminderTime.format(context)}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          value: _mealReminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              _mealReminderEnabled = value;
                              _saveSettings();
                              if (_mealReminderEnabled) {
                                _scheduleMealReminder();
                              } else {
                                flutterLocalNotificationsPlugin.cancel(1);
                              }
                            });
                          },
                          activeColor: accentColor,
                        ),
                        if (_mealReminderEnabled)
                          ListTile(
                            title: Text(
                              'Set Meal Reminder Time',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _pickMealReminderTime,
                          ),
                        SwitchListTile(
                          title: Text(
                            'Water Reminder',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          subtitle: Text(
                            'Time: ${_waterReminderTime.format(context)}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          value: _waterReminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              _waterReminderEnabled = value;
                              _saveSettings();
                              if (_waterReminderEnabled) {
                                _scheduleWaterReminder();
                              } else {
                                flutterLocalNotificationsPlugin.cancel(2);
                              }
                            });
                          },
                          activeColor: accentColor,
                        ),
                        if (_waterReminderEnabled)
                          ListTile(
                            title: Text(
                              'Set Water Reminder Time',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _pickWaterReminderTime,
                          ),
                        SwitchListTile(
                          title: Text(
                            'Workout Reminder',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          subtitle: Text(
                            'Time: ${_workoutReminderTime.format(context)}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          value: _workoutReminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              _workoutReminderEnabled = value;
                              _saveSettings();
                              if (_workoutReminderEnabled) {
                                _scheduleWorkoutReminder();
                              } else {
                                flutterLocalNotificationsPlugin.cancel(3);
                              }
                            });
                          },
                          activeColor: accentColor,
                        ),
                        if (_workoutReminderEnabled)
                          ListTile(
                            title: Text(
                              'Set Workout Reminder Time',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _pickWorkoutReminderTime,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}