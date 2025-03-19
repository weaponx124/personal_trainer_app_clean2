import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String unit = 'lbs';
  String themeMode = 'System'; // Default to system

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedUnit = await DatabaseHelper.getWeightUnit();
    final loadedThemeMode = await DatabaseHelper.getThemeMode();
    setState(() {
      unit = loadedUnit;
      themeMode = _themeModeToString(loadedThemeMode);
    });
  }

  Future<void> _setUnit(String newUnit) async {
    final oldUnit = unit;
    setState(() => unit = newUnit);
    await DatabaseHelper.setWeightUnit(newUnit, currentUnit: oldUnit);
    unitNotifier.value = newUnit;
    Navigator.pop(context);
  }

  Future<void> _setThemeMode(String newThemeMode) async {
    setState(() => themeMode = newThemeMode);
    final mode = _stringToThemeMode(newThemeMode);
    await DatabaseHelper.setThemeMode(mode);
    themeNotifier.value = mode;
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            foregroundColor: const Color(0xFFB0B7BF), // Silver
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
            child: Stack(
              children: [
                // Subtle Cross Background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CrossPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: const Text(
                          'Settings',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFB22222)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Weight Unit',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB22222), // Red
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: unit,
                        items: <String>['lbs', 'kg'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _setUnit(newValue);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Theme Mode',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB22222), // Red
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: themeMode,
                        items: <String>['System', 'Light', 'Dark'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _setThemeMode(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for cross background
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB) // Soft Sky Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double crossSize = 100.0;
    for (double x = 0; x < size.width; x += crossSize * 1.5) {
      for (double y = 0; y < size.height; y += crossSize * 1.5) {
        canvas.drawLine(
          Offset(x + crossSize / 2, y),
          Offset(x + crossSize / 2, y + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(x + crossSize / 4, y + crossSize / 2),
          Offset(x + 3 * crossSize / 4, y + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}