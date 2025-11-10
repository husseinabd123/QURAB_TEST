import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../../config.dart';
import '../models/prayer_settings.dart';

class SettingsRepository {
  SettingsRepository(this._settingsBox);

  final Box _settingsBox;
  PrayerSettings? _cache;

  Future<PrayerSettings> load() async {
    if (_cache != null) return _cache!;
    final stored = _settingsBox.get('settings') as String?;
    if (stored == null) {
      _cache = PrayerSettings.defaults();
      return _cache!;
    }
    final map = jsonDecode(stored) as Map<String, dynamic>;
    _cache = PrayerSettings.fromJson(map);
    return _cache!;
  }

  Future<void> save(PrayerSettings settings) async {
    _cache = settings;
    await _settingsBox.put('settings', jsonEncode(settings.toJson()));
  }

  Future<double> getTasbihCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('tasbih_count') ?? 0;
  }

  Future<void> setTasbihCount(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tasbih_count', value);
  }

  Future<String> getTasbihPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tasbih_pattern') ?? 'fatimah';
  }

  Future<void> setTasbihPattern(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasbih_pattern', pattern);
  }

  Future<void> clearCacheInfo() async {
    await _settingsBox.put(AppConfig.cacheInfoBox, <String, dynamic>{});
  }
}
