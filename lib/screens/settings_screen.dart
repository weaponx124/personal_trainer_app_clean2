import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _weightUnit = 'lbs';
  ThemeMode _themeMode = ThemeMode.system;
  int _weeklyWorkoutGoal = 3; // Default value
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final weightUnit = await DatabaseHelper.getWeightUnit();
    final themeMode = await DatabaseHelper.getThemeMode();
    final weeklyGoal = await DatabaseHelper.getWeeklyWorkoutGoal();
    setState(() {
      _weightUnit = weightUnit;
      _themeMode = themeMode;
      _weeklyWorkoutGoal = weeklyGoal;
      _goalController.text = _weeklyWorkoutGoal.toString();
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
          ),
        ),
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
                  color: const Color(0xFFB22222),
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
                          DatabaseHelper.setWeightUnit(_weightUnit);
                        });
                      },
                      activeColor: const Color(0xFFB22222),
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
                          DatabaseHelper.setWeightUnit(_weightUnit);
                        });
                      },
                      activeColor: const Color(0xFFB22222),
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
                  color: const Color(0xFFB22222),
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
                          DatabaseHelper.setThemeMode(_themeMode);
                        });
                      },
                      activeColor: const Color(0xFFB22222),
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
                          DatabaseHelper.setThemeMode(_themeMode);
                        });
                      },
                      activeColor: const Color(0xFFB22222),
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
                          DatabaseHelper.setThemeMode(_themeMode);
                        });
                      },
                      activeColor: const Color(0xFFB22222),
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
                  color: const Color(0xFFB22222),
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
                  DatabaseHelper.setWeeklyWorkoutGoal(goal);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}