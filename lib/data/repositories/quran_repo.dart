import 'package:hive_flutter/hive_flutter.dart';
import '../models/surah.dart';
import '../models/quran_ayah.dart';
import '../local/json_loader.dart';

class QuranRepository {
  static const String _favoriteSurahsBoxName = 'favorite_surahs';
  static const String _bookmarksBoxName = 'quran_bookmarks';
  static const String _lastReadBoxName = 'last_read_position';

  List<Surah> _surahs = [];
  final Set<int> _favoriteSurahNumbers = {};
  final Set<String> _bookmarkedAyahs = {};

  Future<void> initialize() async {
    await Hive.openBox<int>(_favoriteSurahsBoxName);
    await Hive.openBox<String>(_bookmarksBoxName);
    await Hive.openBox<dynamic>(_lastReadBoxName);
    await _loadSurahs();
    await _loadFavorites();
    await _loadBookmarks();
  }

  Future<void> _loadSurahs() async {
    final data = await JsonLoader.loadQuranIndex();
    _surahs = data.map((json) => Surah.fromJson(json)).toList();
  }

  Future<void> _loadFavorites() async {
    final box = Hive.box<int>(_favoriteSurahsBoxName);
    _favoriteSurahNumbers.addAll(box.values);
    
    // Update favorite status
    for (var surah in _surahs) {
      surah.isFavorite = _favoriteSurahNumbers.contains(surah.number);
    }
  }

  Future<void> _loadBookmarks() async {
    final box = Hive.box<String>(_bookmarksBoxName);
    _bookmarkedAyahs.addAll(box.values);
  }

  List<Surah> getAllSurahs() => _surahs;

  List<Surah> getFavoriteSurahs() {
    return _surahs.where((s) => s.isFavorite).toList();
  }

  List<Surah> searchSurahs(String query) {
    final lowerQuery = query.toLowerCase();
    return _surahs.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
             s.transliteration.toLowerCase().contains(lowerQuery) ||
             s.number.toString().contains(query);
    }).toList();
  }

  Future<void> toggleSurahFavorite(int surahNumber) async {
    final box = Hive.box<int>(_favoriteSurahsBoxName);
    final surah = _surahs.firstWhere((s) => s.number == surahNumber);
    
    surah.isFavorite = !surah.isFavorite;
    
    if (surah.isFavorite) {
      _favoriteSurahNumbers.add(surahNumber);
      await box.put(surahNumber, surahNumber);
    } else {
      _favoriteSurahNumbers.remove(surahNumber);
      await box.delete(surahNumber);
    }
  }

  Future<void> toggleAyahBookmark(int surahNumber, int ayahNumber) async {
    final box = Hive.box<String>(_bookmarksBoxName);
    final key = '$surahNumber:$ayahNumber';
    
    if (_bookmarkedAyahs.contains(key)) {
      _bookmarkedAyahs.remove(key);
      await box.delete(key);
    } else {
      _bookmarkedAyahs.add(key);
      await box.put(key, key);
    }
  }

  bool isAyahBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarkedAyahs.contains('$surahNumber:$ayahNumber');
  }

  List<String> getBookmarkedAyahs() {
    return _bookmarkedAyahs.toList();
  }

  Future<void> saveLastReadPosition(int surahNumber, int ayahNumber) async {
    final box = Hive.box<dynamic>(_lastReadBoxName);
    await box.put('surah', surahNumber);
    await box.put('ayah', ayahNumber);
    await box.put('timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getLastReadPosition() {
    final box = Hive.box<dynamic>(_lastReadBoxName);
    final surah = box.get('surah');
    final ayah = box.get('ayah');
    final timestamp = box.get('timestamp');
    
    if (surah != null && ayah != null) {
      return {
        'surah': surah,
        'ayah': ayah,
        'timestamp': timestamp,
      };
    }
    return null;
  }

  Surah? getSurahByNumber(int number) {
    try {
      return _surahs.firstWhere((s) => s.number == number);
    } catch (e) {
      return null;
    }
  }
}
