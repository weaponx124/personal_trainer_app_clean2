import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color matteBlack = Color(0xFF1C2526);
  static const Color redAccent = Color(0xFFB22222);
  static const Color silver = Color(0xFFB0B7BF);
  static const Color darkGray = Color(0xFF808080);
  static const Color lightBlue = Color(0xFF87CEEB);

  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: matteBlack,
      scaffoldBackgroundColor: matteBlack,
      colorScheme: ColorScheme.light(
        primary: matteBlack,
        secondary: redAccent,
        surface: silver,
        onSurface: matteBlack,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: redAccent,
          ),
          headlineMedium: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: redAccent,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 16,
            color: darkGray,
          ),
          bodySmall: GoogleFonts.roboto(
            fontSize: 14,
            color: darkGray,
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
          backgroundColor: redAccent,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: silver,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: redAccent,
        linearMinHeight: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: redAccent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: matteBlack,
        selectedItemColor: redAccent,
        unselectedItemColor: darkGray,
        elevation: 12,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: matteBlack,
      scaffoldBackgroundColor: matteBlack,
      colorScheme: ColorScheme.dark(
        primary: matteBlack,
        secondary: redAccent,
        surface: silver,
        onSurface: matteBlack,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: redAccent,
          ),
          headlineMedium: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: redAccent,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 16,
            color: darkGray,
          ),
          bodySmall: GoogleFonts.roboto(
            fontSize: 14,
            color: darkGray,
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
          backgroundColor: redAccent,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: silver,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: redAccent,
        linearMinHeight: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: redAccent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: matteBlack,
        selectedItemColor: redAccent,
        unselectedItemColor: darkGray,
        elevation: 12,
      ),
      useMaterial3: true,
    );
  }
}