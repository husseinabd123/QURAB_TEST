import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../../config.dart';
import '../local/json_loader.dart';
import '../models/hadith.dart';

class HadithRepository {
  HadithRepository(this._favoritesBox);

  final Box _favoritesBox;
  List<Hadith>? _cache;

  Future<List<Hadith>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await JsonLoader.loadList('assets/json/hadith.json');
    _cache = raw.map(Hadith.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<List<Hadith>> bySource(String source) async {
    final all = await getAll();
    return all.where((hadith) => hadith.source.contains(source)).toList();
  }

  Future<List<Hadith>> search(String query) async {
    final all = await getAll();
    if (query.isEmpty) return all;
    return all
        .where(
          (hadith) =>
              hadith.text.contains(query) ||
              hadith.tags.any((tag) => tag.contains(query)) ||
              hadith.source.contains(query),
        )
        .toList();
  }

  bool isFavorite(String id) {
    final favs =
        (_favoritesBox.get('ids', defaultValue: <String>[]) as List).cast<String>();
    return favs.contains(id);
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

  Future<List<Hadith>> favorites() async {
    final ids =
        (_favoritesBox.get('ids', defaultValue: <String>[]) as List).cast<String>();
    final all = await getAll();
    return ids
        .map((id) => all.firstWhereOrNull((element) => element.id == id))
        .whereType<Hadith>()
        .toList();
  }
}
