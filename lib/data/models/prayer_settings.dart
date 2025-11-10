class PrayerSettings {
  final String method;
  final String governorate;
  final String city;
  final double latitude;
  final double longitude;
  final bool adhanEnabled;
  final bool hourlyHadithEnabled;
  final int hijriOffset;
  final String themeMode;
  final Map<String, int> offsets;
  final double fontScale;
  final String adhanSoundAsset;
  final bool tasbihHaptic;
  final bool tasbihSound;
  final bool audioCacheEnabled;

  const PrayerSettings({
    required this.method,
    required this.governorate,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.adhanEnabled,
    required this.hourlyHadithEnabled,
    required this.hijriOffset,
    required this.themeMode,
    required this.offsets,
    required this.fontScale,
    required this.adhanSoundAsset,
    required this.tasbihHaptic,
    required this.tasbihSound,
    required this.audioCacheEnabled,
  });

  factory PrayerSettings.defaults() {
    return const PrayerSettings(
      method: 'jafari',
      governorate: 'بغداد',
      city: 'بغداد',
      latitude: 33.3152,
      longitude: 44.3661,
      adhanEnabled: true,
      hourlyHadithEnabled: true,
      hijriOffset: 0,
      themeMode: 'system',
      offsets: {
        'fajr': 0,
        'sunrise': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
      },
      fontScale: 1.0,
      adhanSoundAsset: 'adhan1',
      tasbihHaptic: true,
      tasbihSound: true,
      audioCacheEnabled: true,
    );
  }

  PrayerSettings copyWith({
    String? method,
    String? governorate,
    String? city,
    double? latitude,
    double? longitude,
    bool? adhanEnabled,
    bool? hourlyHadithEnabled,
    int? hijriOffset,
    String? themeMode,
    Map<String, int>? offsets,
    double? fontScale,
    String? adhanSoundAsset,
    bool? tasbihHaptic,
    bool? tasbihSound,
    bool? audioCacheEnabled,
  }) {
    return PrayerSettings(
      method: method ?? this.method,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      hourlyHadithEnabled: hourlyHadithEnabled ?? this.hourlyHadithEnabled,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      themeMode: themeMode ?? this.themeMode,
      offsets: offsets ?? this.offsets,
      fontScale: fontScale ?? this.fontScale,
      adhanSoundAsset: adhanSoundAsset ?? this.adhanSoundAsset,
      tasbihHaptic: tasbihHaptic ?? this.tasbihHaptic,
      tasbihSound: tasbihSound ?? this.tasbihSound,
      audioCacheEnabled: audioCacheEnabled ?? this.audioCacheEnabled,
    );
  }

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    return PrayerSettings(
      method: json['method'] as String? ?? 'jafari',
      governorate: json['governorate'] as String? ?? 'بغداد',
      city: json['city'] as String? ?? 'بغداد',
      latitude: (json['lat'] as num?)?.toDouble() ?? 33.3152,
      longitude: (json['lng'] as num?)?.toDouble() ?? 44.3661,
      adhanEnabled: json['adhan_enabled'] as bool? ?? true,
      hourlyHadithEnabled: json['hourly_hadith_enabled'] as bool? ?? true,
      hijriOffset: json['hijri_offset'] as int? ?? 0,
      themeMode: json['theme'] as String? ?? 'system',
      offsets: (json['offsets'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, (value as num).toInt())),
      fontScale: (json['font_scale'] as num?)?.toDouble() ?? 1.0,
      adhanSoundAsset: json['adhan_sound'] as String? ?? 'adhan1',
      tasbihHaptic: json['tasbih_haptic'] as bool? ?? true,
      tasbihSound: json['tasbih_sound'] as bool? ?? true,
      audioCacheEnabled: json['audio_cache'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'governorate': governorate,
      'city': city,
      'lat': latitude,
      'lng': longitude,
      'adhan_enabled': adhanEnabled,
      'hourly_hadith_enabled': hourlyHadithEnabled,
      'hijri_offset': hijriOffset,
      'theme': themeMode,
      'offsets': offsets,
      'font_scale': fontScale,
      'adhan_sound': adhanSoundAsset,
      'tasbih_haptic': tasbihHaptic,
      'tasbih_sound': tasbihSound,
      'audio_cache': audioCacheEnabled,
    };
  }
}
