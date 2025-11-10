import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../../config.dart';
import '../local/json_loader.dart';
import '../models/dua.dart';

class DuaRepository {
  DuaRepository(this._favoritesBox);

  final Box _favoritesBox;
  List<Dua>? _cache;

  Future<List<Dua>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await JsonLoader.loadList('assets/json/duas.json');
    _cache = raw.map(Dua.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<List<Dua>> search(String query) async {
    final all = await getAll();
    if (query.isEmpty) return all;
    return all
        .where((dua) => dua.title.contains(query) || dua.text.contains(query))
        .toList();
  }

  Future<void> toggleFavorite(String id) async {
    final current =
        (_favoritesBox.get('ids', defaultValue: <String>[]) as List).cast<String>();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await _favoritesBox.put('ids', current);
  }

  bool isFavorite(String id) {
    final favs =
        (_favoritesBox.get('ids', defaultValue: <String>[]) as List).cast<String>();
    return favs.contains(id);
  }

  Future<List<Dua>> favorites() async {
    final ids =
        (_favoritesBox.get('ids', defaultValue: <String>[]) as List).cast<String>();
    final all = await getAll();
    return ids
        .map((id) => all.firstWhereOrNull((element) => element.id == id))
        .whereType<Dua>()
        .toList();
  }
}
