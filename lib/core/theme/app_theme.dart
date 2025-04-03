import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color matteBlack = Color(0xFF1C2526);
  static const Color redAccent = Color(0xFFB22222);
  static const Color silver = Color(0xFFB0B7BF);
  static const Color darkGray = Color(0xFF808080);
  static const Color lightBlue = Color(0xFF87CEEB);
  static const Color proteinColor = Colors.green; // Made const
  static const Color carbsColor = Colors.blue; // Made const
  static const Color fatColor = Colors.orange; // Made const

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
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: redAccent,
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: redAccent,
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