import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Extend ColorScheme to include all theme colors
extension CustomColorScheme on ColorScheme {
  // Progress indicator colors
  /// Color for protein progress indicators (e.g., in MealsTab, DailySummary)
  Color get proteinColor => brightness == Brightness.light ? const Color(0xFF4CAF50) : const Color(0xFF81C784); // Green

  /// Color for carbs progress indicators (e.g., in MealsTab, DailySummary)
  Color get carbsColor => brightness == Brightness.light ? const Color(0xFF2196F3) : const Color(0xFF64B5F6); // Blue

  /// Color for fat progress indicators (e.g., in MealsTab, DailySummary)
  Color get fatColor => brightness == Brightness.light ? const Color(0xFFFFA500) : const Color(0xFFFFB300); // Orange

  // UI element colors
  /// Background color for checked items (e.g., in ShoppingList)
  Color get checkedBackground => brightness == Brightness.light ? const Color(0xFFE0E0E0) : const Color(0xFF424242); // Grey

  /// Icon color for checked items (e.g., in ShoppingList)
  Color get checkedIcon => brightness == Brightness.light ? const Color(0xFF4CAF50) : const Color(0xFF81C784); // Green

  /// Icon color for unchecked items (e.g., in ShoppingList)
  Color get uncheckedIcon => brightness == Brightness.light ? const Color(0xFF808080) : const Color(0xFFB0B7BF); // Grey
}

// Extend ThemeData for custom properties
extension CustomThemeData on ThemeData {
  // Spacing values
  /// Small padding for tight spaces (e.g., between elements within a card)
  double get smallPadding => 8.0;

  /// Medium padding for standard spacing (e.g., card padding)
  double get mediumPadding => 16.0;

  /// Large padding for wider spacing (e.g., section separators)
  double get largePadding => 24.0;

  /// Small spacing for tight gaps (e.g., between text and progress indicators)
  double get smallSpacing => 4.0;

  /// Medium spacing for standard gaps (e.g., between elements in a list)
  double get mediumSpacing => 8.0;

  /// Large spacing for wider gaps (e.g., between sections)
  double get largeSpacing => 16.0;
}

class AppTheme {
  // Core colors
  /// Primary color used for backgrounds and text (e.g., scaffold background, primary text)
  static const Color matteBlack = Color(0xFF1C2526);

  /// Accent color used for buttons, icons, and highlights (e.g., ElevatedButton, FAB)
  static const Color redAccent = Color(0xFFB22222);

  /// Surface color used for cards and backgrounds (e.g., Card background)
  static const Color silver = Color(0xFFB0B7BF);

  /// Secondary text color (e.g., subtitles, nutritional details)
  static const Color darkGray = Color(0xFF808080);

  /// Light blue color used in the background gradient (e.g., AppBackground)
  static const Color lightBlue = Color(0xFF87CEEB);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.light(
      primary: matteBlack,
      onPrimary: Colors.white,
      secondary: redAccent,
      onSecondary: Colors.white,
      surface: silver,
      onSurface: matteBlack,
      onSurfaceVariant: darkGray,
      background: Colors.transparent,
      onBackground: matteBlack,
    );

    return ThemeData(
      primaryColor: matteBlack,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
          headlineMedium: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
          titleMedium: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          bodySmall: GoogleFonts.roboto(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          titleSmall: GoogleFonts.roboto(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
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
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.secondary,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        linearMinHeight: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: matteBlack,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: darkGray,
        elevation: 12,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: matteBlack,
      onPrimary: Colors.white,
      secondary: redAccent,
      onSecondary: Colors.white,
      surface: const Color(0xFF2A2A2A), // Darker surface for cards
      onSurface: Colors.white,
      onSurfaceVariant: silver, // Lighter grey for secondary text
      background: Colors.transparent,
      onBackground: Colors.white,
    );

    return ThemeData(
      primaryColor: matteBlack,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
          headlineMedium: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
          titleMedium: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          bodySmall: GoogleFonts.roboto(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          titleSmall: GoogleFonts.roboto(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
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
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.secondary,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surface,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        linearMinHeight: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: matteBlack,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: silver, // Lighter grey for better contrast
        elevation: 12,
      ),
      useMaterial3: true,
    );
  }
}