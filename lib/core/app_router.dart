import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/adhkar/adhkar_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_list_screen.dart';
import '../features/quran/reader_screen.dart';
import '../features/hadith/hadith_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/duas/duas_screen.dart';
import '../features/tasbih/tasbih_screen.dart';
import '../features/home/more_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeDashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/adhkar',
                name: 'adhkar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AdhkarScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/qibla',
                name: 'qibla',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: QiblaScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MoreScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranScreen(),
        routes: [
          GoRoute(
            path: 'surahs',
            name: 'surah_list',
            builder: (context, state) => const SurahListScreen(),
          ),
          GoRoute(
            path: 'reader/:id',
            name: 'surah_reader',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id'] ?? '1');
              return ReaderScreen(surahNumber: id);
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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  ),
);
