import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'styles.dart';

ThemeData buildLightTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.lightOlive,
    brightness: Brightness.light,
    primary: AppPalette.lightOlive,
    secondary: AppPalette.lightGold,
    background: AppPalette.lightBackground,
    surface: AppPalette.lightSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: AppPalette.lightText,
    onSurface: AppPalette.lightText,
  );

  return ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.lightBackground,
      elevation: 0,
      foregroundColor: AppPalette.lightText,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    ),
    cardTheme: CardTheme(
      color: AppPalette.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: AppPalette.lightOlive.withOpacity(0.15),
    ),
    textTheme: AppTextStyles.textTheme(AppPalette.lightText, AppPalette.lightMuted),
    iconTheme: const IconThemeData(color: AppPalette.lightOlive, size: 22),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPalette.lightSurface,
      selectedItemColor: AppPalette.lightOlive,
      unselectedItemColor: AppPalette.lightMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.lightGold,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.lightSurface,
      selectedColor: AppPalette.lightGold.withOpacity(0.18),
      labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500),
      side: BorderSide(color: AppPalette.lightOlive.withOpacity(0.2)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );
}

ThemeData buildDarkTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.darkOlive,
    brightness: Brightness.dark,
    primary: AppPalette.darkOlive,
    secondary: AppPalette.darkGold,
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: AppPalette.darkText,
    onSurface: AppPalette.darkText,
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.darkBackground,
      elevation: 0,
      foregroundColor: AppPalette.darkText,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    ),
    cardTheme: CardTheme(
      color: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: AppPalette.darkGold.withOpacity(0.08),
    ),
    textTheme: AppTextStyles.textTheme(AppPalette.darkText, AppPalette.darkMuted),
    iconTheme: const IconThemeData(color: AppPalette.darkGold, size: 22),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPalette.darkSurface,
      selectedItemColor: AppPalette.darkGold,
      unselectedItemColor: AppPalette.darkMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.darkGold,
      foregroundColor: Colors.black,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.darkSurface,
      selectedColor: AppPalette.darkGold.withOpacity(0.2),
      labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500),
      side: BorderSide(color: AppPalette.darkGold.withOpacity(0.2)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );
}
