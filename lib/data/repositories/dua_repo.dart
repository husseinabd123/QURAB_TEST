import 'package:hive_flutter/hive_flutter.dart';
import '../models/dua.dart';
import '../local/json_loader.dart';

class DuaRepository {
  static const String _favoritesBoxName = 'favorite_duas';

  List<Dua> _duas = [];
  final Set<String> _favoriteIds = {};

  Future<void> initialize() async {
    await Hive.openBox<String>(_favoritesBoxName);
    await _loadDuas();
    await _loadFavorites();
  }

  Future<void> _loadDuas() async {
    final data = await JsonLoader.loadDuasData();
    _duas = data.map((json) => Dua.fromJson(json)).toList();
  }

  Future<void> _loadFavorites() async {
    final box = Hive.box<String>(_favoritesBoxName);
    _favoriteIds.addAll(box.values);
    
    // Update favorite status
    for (var dua in _duas) {
      dua.isFavorite = _favoriteIds.contains(dua.id);
    }
  }

  List<Dua> getAllDuas() => _duas;

  List<Dua> getFavoriteDuas() {
    return _duas.where((d) => d.isFavorite).toList();
  }

  List<Dua> searchDuas(String query) {
    final lowerQuery = query.toLowerCase();
    return _duas.where((d) {
      return d.title.toLowerCase().contains(lowerQuery) ||
             d.text.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> toggleFavorite(String duaId) async {
    final box = Hive.box<String>(_favoritesBoxName);
    final dua = _duas.firstWhere((d) => d.id == duaId);
    
    dua.isFavorite = !dua.isFavorite;
    
    if (dua.isFavorite) {
      _favoriteIds.add(duaId);
      await box.put(duaId, duaId);
    } else {
      _favoriteIds.remove(duaId);
      await box.delete(duaId);
    }
  }

  Dua? getDuaById(String id) {
    try {
      return _duas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
