import 'package:hive_flutter/hive_flutter.dart';
import '../models/hadith.dart';
import '../local/json_loader.dart';

class HadithRepository {
  static const String _boxName = 'hadiths';
  static const String _favoritesBoxName = 'favorite_hadiths';

  List<Hadith> _hadiths = [];
  final Set<String> _favoriteIds = {};

  Future<void> initialize() async {
    await Hive.openBox<String>(_favoritesBoxName);
    await _loadHadiths();
    await _loadFavorites();
  }

  Future<void> _loadHadiths() async {
    final data = await JsonLoader.loadHadithData();
    _hadiths = data.map((json) => Hadith.fromJson(json)).toList();
  }

  Future<void> _loadFavorites() async {
    final box = Hive.box<String>(_favoritesBoxName);
    _favoriteIds.addAll(box.values);
    
    // Update favorite status
    for (var hadith in _hadiths) {
      hadith.isFavorite = _favoriteIds.contains(hadith.id);
    }
  }

  List<Hadith> getAllHadiths() => _hadiths;

  List<Hadith> getHadithsBySource(String source) {
    return _hadiths.where((h) => h.source == source).toList();
  }

  List<Hadith> getFavoriteHadiths() {
    return _hadiths.where((h) => h.isFavorite).toList();
  }

  List<Hadith> searchHadiths(String query) {
    final lowerQuery = query.toLowerCase();
    return _hadiths.where((h) {
      return h.text.toLowerCase().contains(lowerQuery) ||
             h.source.toLowerCase().contains(lowerQuery) ||
             h.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> toggleFavorite(String hadithId) async {
    final box = Hive.box<String>(_favoritesBoxName);
    final hadith = _hadiths.firstWhere((h) => h.id == hadithId);
    
    hadith.isFavorite = !hadith.isFavorite;
    
    if (hadith.isFavorite) {
      _favoriteIds.add(hadithId);
      await box.put(hadithId, hadithId);
    } else {
      _favoriteIds.remove(hadithId);
      await box.delete(hadithId);
    }
  }

  Hadith? getHadithById(String id) {
    try {
      return _hadiths.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getAllSources() {
    return _hadiths.map((h) => h.source).toSet().toList();
  }
}
