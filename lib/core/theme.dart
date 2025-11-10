import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF7F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF8A9A5B);
  static const Color lightAccent = Color(0xFFD4AF37);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F1411);
  static const Color darkSurface = Color(0xFF1A1F1C);
  static const Color darkPrimary = Color(0xFF9BB87D);
  static const Color darkAccent = Color(0xFFE0C778);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Cairo',
      
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightAccent,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
      ),
      
      scaffoldBackgroundColor: lightBackground,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightText),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightText),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: lightText),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightText),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightText),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightText),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightText),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: lightText, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightText, height: 1.5),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: lightTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightText),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightText),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: lightTextSecondary),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPrimary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPrimary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      dividerTheme: DividerThemeData(
        color: lightPrimary.withOpacity(0.2),
        thickness: 1,
      ),
      
      iconTheme: const IconThemeData(
        color: lightPrimary,
        size: 24,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
      
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkAccent,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: darkText,
      ),
      
      scaffoldBackgroundColor: darkBackground,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkText),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkText),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkText),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkText),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkText, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkText, height: 1.5),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: darkTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkText),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextSecondary),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      dividerTheme: DividerThemeData(
        color: darkPrimary.withOpacity(0.2),
        thickness: 1,
      ),
      
      iconTheme: const IconThemeData(
        color: darkPrimary,
        size: 24,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 12),
      ),
    );
  }
}
