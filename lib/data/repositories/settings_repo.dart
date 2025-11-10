import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer_settings.dart';

class SettingsRepository {
  static const String _settingsKey = 'app_settings';
  static const String _tasbihCountKey = 'tasbih_count';
  static const String _tasbihPatternKey = 'tasbih_pattern';
  static const String _tasbihTargetKey = 'tasbih_target';

  late SharedPreferences _prefs;
  late PrayerSettings _settings;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString != null) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _settings = PrayerSettings.fromJson(json);
    } else {
      // Default settings
      _settings = PrayerSettings();
      await saveSettings(_settings);
    }
  }

  PrayerSettings getSettings() => _settings;

  Future<void> saveSettings(PrayerSettings settings) async {
    _settings = settings;
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  Future<void> updateMethod(String method) async {
    _settings = _settings.copyWith(method: method);
    await saveSettings(_settings);
  }

  Future<void> updateCity(String city) async {
    _settings = _settings.copyWith(city: city);
    await saveSettings(_settings);
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    _settings = _settings.copyWith(latitude: latitude, longitude: longitude);
    await saveSettings(_settings);
  }

  Future<void> updateAdhanEnabled(bool enabled) async {
    _settings = _settings.copyWith(adhanEnabled: enabled);
    await saveSettings(_settings);
  }

  Future<void> updateHourlyHadithEnabled(bool enabled) async {
    _settings = _settings.copyWith(hourlyHadithEnabled: enabled);
    await saveSettings(_settings);
  }

  Future<void> updateHijriOffset(int offset) async {
    _settings = _settings.copyWith(hijriOffset: offset);
    await saveSettings(_settings);
  }

  Future<void> updateTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    await saveSettings(_settings);
  }

  Future<void> updatePrayerOffset(String prayer, int offset) async {
    final newOffsets = Map<String, int>.from(_settings.offsets);
    newOffsets[prayer] = offset;
    _settings = _settings.copyWith(offsets: newOffsets);
    await saveSettings(_settings);
  }

  Future<void> updateAdhanSound(String? path) async {
    _settings = _settings.copyWith(adhanSoundPath: path);
    await saveSettings(_settings);
  }

  Future<void> updateFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    await saveSettings(_settings);
  }

  // Tasbih settings
  int getTasbihCount() => _prefs.getInt(_tasbihCountKey) ?? 0;
  
  Future<void> saveTasbihCount(int count) async {
    await _prefs.setInt(_tasbihCountKey, count);
  }

  String getTasbihPattern() => _prefs.getString(_tasbihPatternKey) ?? 'fatimah';
  
  Future<void> saveTasbihPattern(String pattern) async {
    await _prefs.setString(_tasbihPatternKey, pattern);
  }

  int getTasbihTarget() => _prefs.getInt(_tasbihTargetKey) ?? 33;
  
  Future<void> saveTasbihTarget(int target) async {
    await _prefs.setInt(_tasbihTargetKey, target);
  }

  // Other preferences
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
