import 'package:hive_flutter/hive_flutter.dart';
import '../models/dhikr.dart';
import '../local/json_loader.dart';

class DhikrRepository {
  static const String _progressBoxName = 'dhikr_progress';

  List<Dhikr> _adhkar = [];

  Future<void> initialize() async {
    await Hive.openBox<int>(_progressBoxName);
    await _loadAdhkar();
    await _loadProgress();
  }

  Future<void> _loadAdhkar() async {
    final data = await JsonLoader.loadAdhkarData();
    _adhkar = data.map((json) => Dhikr.fromJson(json)).toList();
  }

  Future<void> _loadProgress() async {
    final box = Hive.box<int>(_progressBoxName);
    for (var dhikr in _adhkar) {
      dhikr.currentCount = box.get(dhikr.id, defaultValue: 0) ?? 0;
    }
  }

  List<Dhikr> getAllAdhkar() => _adhkar;

  List<Dhikr> getAdhkarByTime(DhikrTime time) {
    return _adhkar.where((d) => d.dhikrTime == time).toList();
  }

  List<Dhikr> getMorningAdhkar() {
    return _adhkar.where((d) => d.time == 'morning').toList();
  }

  List<Dhikr> getEveningAdhkar() {
    return _adhkar.where((d) => d.time == 'evening').toList();
  }

  List<Dhikr> getAfterPrayerAdhkar() {
    return _adhkar.where((d) => d.time == 'after_prayer').toList();
  }

  Future<void> incrementCount(String dhikrId) async {
    final dhikr = _adhkar.firstWhere((d) => d.id == dhikrId);
    if (dhikr.currentCount < dhikr.repeatCount) {
      dhikr.currentCount++;
      await _saveProgress(dhikrId, dhikr.currentCount);
    }
  }

  Future<void> decrementCount(String dhikrId) async {
    final dhikr = _adhkar.firstWhere((d) => d.id == dhikrId);
    if (dhikr.currentCount > 0) {
      dhikr.currentCount--;
      await _saveProgress(dhikrId, dhikr.currentCount);
    }
  }

  Future<void> resetCount(String dhikrId) async {
    final dhikr = _adhkar.firstWhere((d) => d.id == dhikrId);
    dhikr.currentCount = 0;
    await _saveProgress(dhikrId, 0);
  }

  Future<void> resetAllCounts() async {
    final box = Hive.box<int>(_progressBoxName);
    await box.clear();
    for (var dhikr in _adhkar) {
      dhikr.currentCount = 0;
    }
  }

  Future<void> _saveProgress(String dhikrId, int count) async {
    final box = Hive.box<int>(_progressBoxName);
    await box.put(dhikrId, count);
  }

  Dhikr? getDhikrById(String id) {
    try {
      return _adhkar.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}
