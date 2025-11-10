import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_list_screen.dart';
import '../features/quran/reader_screen.dart';
import '../features/hadith/hadith_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/duas/duas_screen.dart';
import '../features/tasbih/tasbih_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/adhkar/adhkar_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranScreen(),
        routes: [
          GoRoute(
            path: 'surahs',
            name: 'surah-list',
            builder: (context, state) => const SurahListScreen(),
          ),
          GoRoute(
            path: 'reader/:surahNumber',
            name: 'reader',
            builder: (context, state) {
              final surahNumber = int.parse(state.pathParameters['surahNumber']!);
              return ReaderScreen(surahNumber: surahNumber);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/hadith',
        name: 'hadith',
        builder: (context, state) => const HadithScreen(),
      ),
      GoRoute(
        path: '/prayer',
        name: 'prayer',
        builder: (context, state) => const PrayerScreen(),
      ),
      GoRoute(
        path: '/duas',
        name: 'duas',
        builder: (context, state) => const DuasScreen(),
      ),
      GoRoute(
        path: '/tasbih',
        name: 'tasbih',
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/adhkar',
        name: 'adhkar',
        builder: (context, state) => const AdhkarScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير موجودة',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  );
}
