import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../config.dart';
import '../data/models/prayer_settings.dart';
import '../data/repositories/dhikr_repo.dart';
import '../data/repositories/dua_repo.dart';
import '../data/repositories/hadith_repo.dart';
import '../data/repositories/quran_repo.dart';
import '../data/repositories/settings_repo.dart';

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  final box = Hive.box(AppConfig.hadithFavoritesBox);
  return HadithRepository(box);
});

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  final box = Hive.box(AppConfig.duaFavoritesBox);
  return DuaRepository(box);
});

final dhikrRepositoryProvider = Provider<DhikrRepository>((ref) {
  return DhikrRepository();
});

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final bookmarks = Hive.box(AppConfig.quranBookmarksBox);
  final recents = Hive.box(AppConfig.quranRecentsBox);
  return QuranRepository(bookmarks, recents);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final box = Hive.box(AppConfig.settingsBox);
  return SettingsRepository(box);
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<PrayerSettings>>(
  (ref) {
    final repo = ref.watch(settingsRepositoryProvider);
    return SettingsController(repo);
  },
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return settings.when(
    data: (value) {
      switch (value.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    },
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

final fontScaleProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return settings.maybeWhen(
    data: (value) => value.fontScale,
    orElse: () => 1.0,
  );
});

class SettingsController
    extends StateNotifier<AsyncValue<PrayerSettings>> {
  SettingsController(this._repository)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final settings = await _repository.load();
      state = AsyncValue.data(settings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> update(PrayerSettings settings) async {
    state = AsyncValue.data(settings);
    await _repository.save(settings);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final current = state.value ?? PrayerSettings.defaults();
    final updated = current.copyWith(
      themeMode: switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
    await update(updated);
  }

  Future<void> updateFontScale(double scale) async {
    final current = state.value ?? PrayerSettings.defaults();
    await update(current.copyWith(fontScale: scale));
  }

  Future<void> toggleAdhan(bool enabled) async {
    final current = state.value ?? PrayerSettings.defaults();
    await update(current.copyWith(adhanEnabled: enabled));
  }

  Future<void> toggleHourlyHadith(bool enabled) async {
    final current = state.value ?? PrayerSettings.defaults();
    await update(current.copyWith(hourlyHadithEnabled: enabled));
  }
}
