import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../data/repositories/hadith_repo.dart';
import '../data/repositories/dua_repo.dart';
import '../data/repositories/dhikr_repo.dart';
import '../data/repositories/quran_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/models/hadith.dart';
import '../data/models/dua.dart';
import '../data/models/dhikr.dart';
import '../data/models/surah.dart';
import '../data/models/prayer_settings.dart';

// Repository Providers
final hadithRepoProvider = Provider<HadithRepository>((ref) {
  final repo = HadithRepository();
  repo.initialize();
  return repo;
});

final duaRepoProvider = Provider<DuaRepository>((ref) {
  final repo = DuaRepository();
  repo.initialize();
  return repo;
});

final dhikrRepoProvider = Provider<DhikrRepository>((ref) {
  final repo = DhikrRepository();
  repo.initialize();
  return repo;
});

final quranRepoProvider = Provider<QuranRepository>((ref) {
  final repo = QuranRepository();
  repo.initialize();
  return repo;
});

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  final repo = SettingsRepository();
  repo.initialize();
  return repo;
});

// Data Providers
final hadithListProvider = FutureProvider<List<Hadith>>((ref) async {
  final repo = ref.watch(hadithRepoProvider);
  return repo.getAllHadiths();
});

final duaListProvider = FutureProvider<List<Dua>>((ref) async {
  final repo = ref.watch(duaRepoProvider);
  return repo.getAllDuas();
});

final adhkarListProvider = FutureProvider<List<Dhikr>>((ref) async {
  final repo = ref.watch(dhikrRepoProvider);
  return repo.getAllAdhkar();
});

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepoProvider);
  return repo.getAllSurahs();
});

final settingsProvider = FutureProvider<PrayerSettings>((ref) async {
  final repo = ref.watch(settingsRepoProvider);
  return repo.getSettings();
});

// Theme Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(String mode) {
    switch (mode) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }
}

// Search Query Providers
final hadithSearchQueryProvider = StateProvider<String>((ref) => '');
final quranSearchQueryProvider = StateProvider<String>((ref) => '');
final duaSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Lists
final filteredHadithsProvider = Provider<List<Hadith>>((ref) {
  final hadiths = ref.watch(hadithListProvider).valueOrNull ?? [];
  final query = ref.watch(hadithSearchQueryProvider);
  
  if (query.isEmpty) return hadiths;
  
  final repo = ref.watch(hadithRepoProvider);
  return repo.searchHadiths(query);
});

final filteredSurahsProvider = Provider<List<Surah>>((ref) {
  final surahs = ref.watch(surahListProvider).valueOrNull ?? [];
  final query = ref.watch(quranSearchQueryProvider);
  
  if (query.isEmpty) return surahs;
  
  final repo = ref.watch(quranRepoProvider);
  return repo.searchSurahs(query);
});

final filteredDuasProvider = Provider<List<Dua>>((ref) {
  final duas = ref.watch(duaListProvider).valueOrNull ?? [];
  final query = ref.watch(duaSearchQueryProvider);
  
  if (query.isEmpty) return duas;
  
  final repo = ref.watch(duaRepoProvider);
  return repo.searchDuas(query);
});

// Favorites
final favoriteHadithsProvider = Provider<List<Hadith>>((ref) {
  final repo = ref.watch(hadithRepoProvider);
  return repo.getFavoriteHadiths();
});

final favoriteSurahsProvider = Provider<List<Surah>>((ref) {
  final repo = ref.watch(quranRepoProvider);
  return repo.getFavoriteSurahs();
});

final favoriteDuasProvider = Provider<List<Dua>>((ref) {
  final repo = ref.watch(duaRepoProvider);
  return repo.getFavoriteDuas();
});

// Tasbih State
final tasbihCountProvider = StateNotifierProvider<TasbihCountNotifier, int>((ref) {
  return TasbihCountNotifier(ref);
});

class TasbihCountNotifier extends StateNotifier<int> {
  final Ref ref;
  
  TasbihCountNotifier(this.ref) : super(0) {
    _loadCount();
  }

  Future<void> _loadCount() async {
    final repo = ref.read(settingsRepoProvider);
    state = repo.getTasbihCount();
  }

  Future<void> increment() async {
    state++;
    final repo = ref.read(settingsRepoProvider);
    await repo.saveTasbihCount(state);
  }

  Future<void> decrement() async {
    if (state > 0) {
      state--;
      final repo = ref.read(settingsRepoProvider);
      await repo.saveTasbihCount(state);
    }
  }

  Future<void> reset() async {
    state = 0;
    final repo = ref.read(settingsRepoProvider);
    await repo.saveTasbihCount(0);
  }
}

// Bottom Navigation Index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
