import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const lightBackground = Color(0xFFF7F4EC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOlive = Color(0xFF8A9A5B);
  static const lightGold = Color(0xFFD4AF37);
  static const lightText = Color(0xFF1E1A16);
  static const lightMuted = Color(0xFF6D665C);

  static const darkBackground = Color(0xFF0F1411);
  static const darkSurface = Color(0xFF1B211D);
  static const darkOlive = Color(0xFF9BB87D);
  static const darkGold = Color(0xFFE0C778);
  static const darkText = Color(0xFFF5F0E6);
  static const darkMuted = Color(0xFF8E988C);
}

class AppTextStyles {
  static TextTheme textTheme(Color color, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
    );
  }
}
