import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:workmanager/workmanager.dart';

import 'config.dart';
import 'core/app_router.dart';
import 'core/background.dart';
import 'core/notifications.dart';
import 'core/permissions.dart';
import 'core/theme.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _openCoreBoxes();
  await AppNotifications.initialize();
  await PermissionsHandler.ensureNotificationChannelSetup();
  await JustAudioBackground.init(
    androidNotificationChannelId: AppConfig.adhanNotificationChannelId,
    androidNotificationChannelName: AppConfig.adhanNotificationChannelName,
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  await Workmanager().initialize(
    BackgroundDispatcher.callbackDispatcher,
    isInDebugMode: false,
  );
  await BackgroundDispatcher.registerHourlyHadithTask();

  Intl.defaultLocale = AppConfig.defaultLocale.toLanguageTag();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: HakibatApp()));
}

Future<void> _openCoreBoxes() async {
  await Future.wait([
    Hive.openBox(AppConfig.quranBookmarksBox),
    Hive.openBox(AppConfig.quranRecentsBox),
    Hive.openBox(AppConfig.hadithFavoritesBox),
    Hive.openBox(AppConfig.duaFavoritesBox),
    Hive.openBox(AppConfig.adhkarProgressBox),
    Hive.openBox(AppConfig.tasbihBox),
    Hive.openBox(AppConfig.settingsBox),
    Hive.openBox(AppConfig.cacheInfoBox),
  ]);
}

class HakibatApp extends ConsumerWidget {
  const HakibatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: AppConfig.defaultLocale,
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final fontScale = ref.watch(fontScaleProvider);
        return MediaQuery(
          data: media.copyWith(
            textScaleFactor: media.textScaleFactor * fontScale,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: buildLightTheme(context),
      darkTheme: buildDarkTheme(context),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
