import 'package:hive/hive.dart';

part 'prayer_settings.g.dart';

@HiveType(typeId: 5)
class PrayerSettings {
  @HiveField(0)
  String method;

  @HiveField(1)
  String? city;

  @HiveField(2)
  double? latitude;

  @HiveField(3)
  double? longitude;

  @HiveField(4)
  bool adhanEnabled;

  @HiveField(5)
  bool hourlyHadithEnabled;

  @HiveField(6)
  int hijriOffset;

  @HiveField(7)
  String theme;

  @HiveField(8)
  Map<String, int> offsets;

  @HiveField(9)
  String? adhanSoundPath;

  @HiveField(10)
  double fontSize;

  PrayerSettings({
    this.method = 'jafari',
    this.city,
    this.latitude,
    this.longitude,
    this.adhanEnabled = true,
    this.hourlyHadithEnabled = false,
    this.hijriOffset = 0,
    this.theme = 'system',
    Map<String, int>? offsets,
    this.adhanSoundPath,
    this.fontSize = 1.0,
  }) : offsets = offsets ?? {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0};

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    return PrayerSettings(
      method: json['method'] as String? ?? 'jafari',
      city: json['city'] as String?,
      latitude: json['lat'] as double?,
      longitude: json['lng'] as double?,
      adhanEnabled: json['adhan_enabled'] as bool? ?? true,
      hourlyHadithEnabled: json['hourly_hadith_enabled'] as bool? ?? false,
      hijriOffset: json['hijri_offset'] as int? ?? 0,
      theme: json['theme'] as String? ?? 'system',
      offsets: (json['offsets'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0},
      adhanSoundPath: json['adhan_sound'] as String?,
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'city': city,
      'lat': latitude,
      'lng': longitude,
      'adhan_enabled': adhanEnabled,
      'hourly_hadith_enabled': hourlyHadithEnabled,
      'hijri_offset': hijriOffset,
      'theme': theme,
      'offsets': offsets,
      'adhan_sound': adhanSoundPath,
      'font_size': fontSize,
    };
  }

  PrayerSettings copyWith({
    String? method,
    String? city,
    double? latitude,
    double? longitude,
    bool? adhanEnabled,
    bool? hourlyHadithEnabled,
    int? hijriOffset,
    String? theme,
    Map<String, int>? offsets,
    String? adhanSoundPath,
    double? fontSize,
  }) {
    return PrayerSettings(
      method: method ?? this.method,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      hourlyHadithEnabled: hourlyHadithEnabled ?? this.hourlyHadithEnabled,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      theme: theme ?? this.theme,
      offsets: offsets ?? this.offsets,
      adhanSoundPath: adhanSoundPath ?? this.adhanSoundPath,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  Map<String, DateTime> toMap() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  List<MapEntry<String, DateTime>> toPrayerList() {
    return [
      MapEntry('الفجر', fajr),
      MapEntry('الشروق', sunrise),
      MapEntry('الظهر', dhuhr),
      MapEntry('العصر', asr),
      MapEntry('المغرب', maghrib),
      MapEntry('العشاء', isha),
    ];
  }
}
