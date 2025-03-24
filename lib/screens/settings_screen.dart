import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/verse_of_the_day_repository.dart';
import 'package:personal_trainer_app_clean/core/services/notification_service.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'dart:io' show Platform;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final VerseOfTheDayRepository _verseOfTheDayRepository = VerseOfTheDayRepository();
  NotificationService? _notificationService;
  String _weightUnit = 'lbs';
  ThemeMode _themeMode = ThemeMode.system;
  int _weeklyWorkoutGoal = 3;
  String _fitnessGoal = 'strength';
  String _experienceLevel = 'beginner';
  String _preferredWorkoutType = 'strength';
  Color _accentColor = const Color(0xFFB22222);
  final TextEditingController _goalController = TextEditingController();
  bool _mealReminderEnabled = false;
  bool _waterReminderEnabled = false;
  bool _workoutReminderEnabled = false;
  Map<String, TimeOfDay> _mealReminderTimes = {
    'Breakfast': const TimeOfDay(hour: 8, minute: 0),
    'Lunch': const TimeOfDay(hour: 12, minute: 0),
    'Dinner': const TimeOfDay(hour: 18, minute: 0),
    'Snack': const TimeOfDay(hour: 15, minute: 0),
  };
  TimeOfDay _waterReminderTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    try {
      print('SettingsScreen: Initializing notification service...');
      final notificationPlugin = await flutterLocalNotificationsPluginFuture;
      if (notificationPlugin != null) {
        _notificationService = NotificationService(notificationPlugin);
        print('SettingsScreen: Notification service initialized.');
      } else {
        print('SettingsScreen: Notification service not initialized (unsupported platform, e.g., Windows).');
      }
      await _loadSettings();
    } catch (e) {
      print('SettingsScreen: Error initializing notification service: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    final mealReminderEnabled = await _settingsRepository.getMealReminderEnabled();
    final waterReminderEnabled = await _settingsRepository.getWaterReminderEnabled();
    final workoutReminderEnabled = await _settingsRepository.getWorkoutReminderEnabled();
    final mealReminderTimes = await _settingsRepository.getMealReminderTimes();
    final waterReminderTime = await _settingsRepository.getWaterReminderTime();
    final workoutReminderTime = await _settingsRepository.getWorkoutReminderTime();

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
      _mealReminderTimes = mealReminderTimes;
      _waterReminderTime = waterReminderTime;
      _workoutReminderTime = workoutReminderTime;
      _goalController.text = _weeklyWorkoutGoal.toString();
      unitNotifier.value = _weightUnit;
      themeModeNotifier.value = _themeMode;
      accentColorNotifier.value = _accentColor;
      _isLoading = false;
    });

    // Schedule notifications if enabled and the service is available
    if (_notificationService != null) {
      if (_mealReminderEnabled) await _notificationService!.scheduleMealNotifications();
      if (_waterReminderEnabled) await _notificationService!.scheduleWaterNotifications();
      if (_workoutReminderEnabled) await _notificationService!.scheduleWorkoutNotifications();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', _accentColor.value);
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

  Future<void> _pickMealReminderTime(String mealType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _mealReminderTimes[mealType]!,
    );
    if (picked != null) {
      final updatedTimes = Map<String, TimeOfDay>.from(_mealReminderTimes);
      updatedTimes[mealType] = picked;
      await _settingsRepository.setMealReminderTimes(updatedTimes);
      setState(() {
        _mealReminderTimes = updatedTimes;
      });
      if (_mealReminderEnabled && _notificationService != null) {
        await _notificationService!.scheduleMealNotifications();
      }
    }
  }

  Future<void> _pickWaterReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waterReminderTime,
    );
    if (picked != null) {
      await _settingsRepository.setWaterReminderTime(picked);
      setState(() {
        _waterReminderTime = picked;
      });
      if (_waterReminderEnabled && _notificationService != null) {
        await _notificationService!.scheduleWaterNotifications();
      }
    }
  }

  Future<void> _pickWorkoutReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _workoutReminderTime,
    );
    if (picked != null) {
      await _settingsRepository.setWorkoutReminderTime(picked);
      setState(() {
        _workoutReminderTime = picked;
      });
      if (_workoutReminderEnabled && _notificationService != null) {
        await _notificationService!.scheduleWorkoutNotifications();
      }
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                          value: _mealReminderEnabled,
                          onChanged: (value) async {
                            await _settingsRepository.setMealReminderEnabled(value);
                            setState(() {
                              _mealReminderEnabled = value;
                            });
                            if (_notificationService != null) {
                              if (_mealReminderEnabled) {
                                await _notificationService!.scheduleMealNotifications();
                              } else {
                                await _notificationService!.cancelAllNotifications();
                              }
                            }
                          },
                          activeColor: accentColor,
                        ),
                        if (_mealReminderEnabled) ...[
                          ..._mealReminderTimes.entries.map((entry) {
                            final mealType = entry.key;
                            final time = entry.value;
                            return ListTile(
                              title: Text(
                                '$mealType Reminder Time',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFF1C2526),
                                ),
                              ),
                              subtitle: Text(
                                'Time: ${time.format(context)}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _pickMealReminderTime(mealType),
                            );
                          }).toList(),
                        ],
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
                          onChanged: (value) async {
                            await _settingsRepository.setWaterReminderEnabled(value);
                            setState(() {
                              _waterReminderEnabled = value;
                            });
                            if (_notificationService != null) {
                              if (_waterReminderEnabled) {
                                await _notificationService!.scheduleWaterNotifications();
                              } else {
                                await _notificationService!.cancelAllNotifications();
                              }
                            }
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
                          onChanged: (value) async {
                            await _settingsRepository.setWorkoutReminderEnabled(value);
                            setState(() {
                              _workoutReminderEnabled = value;
                            });
                            if (_notificationService != null) {
                              if (_workoutReminderEnabled) {
                                await _notificationService!.scheduleWorkoutNotifications();
                              } else {
                                await _notificationService!.cancelAllNotifications();
                              }
                            }
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
    return "${this[0].toUpperCase}${substring(1)}";
  }
}