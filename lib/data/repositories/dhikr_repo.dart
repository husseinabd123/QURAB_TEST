import '../local/json_loader.dart';
import '../models/dhikr.dart';

class DhikrRepository {
  List<Dhikr>? _cache;

  Future<List<Dhikr>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await JsonLoader.loadList('assets/json/adhkar.json');
    _cache = raw.map(Dhikr.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<List<Dhikr>> byTime(String time) async {
    final all = await getAll();
    if (time == 'all') return all;
    return all.where((dhikr) => dhikr.time == time || dhikr.time == 'any').toList();
  }
}
