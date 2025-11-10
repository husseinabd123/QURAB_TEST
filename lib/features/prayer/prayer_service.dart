import 'dart:math';

import 'package:intl/intl.dart';

import '../../core/utils.dart';
import '../../data/models/prayer_settings.dart';

class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<MapEntry<String, DateTime>> asEntries() => [
        MapEntry('الفجر', fajr),
        MapEntry('الشروق', sunrise),
        MapEntry('الظهر', dhuhr),
        MapEntry('العصر', asr),
        MapEntry('المغرب', maghrib),
        MapEntry('العشاء', isha),
      ];
}

class JafariPrayerCalculator {
  static const double fajrAngle = 16;
  static const double ishaAngle = 14;
  static const double shadowFactor = 1.0;

  PrayerTimes calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required int timezoneOffsetMinutes,
    Map<String, int> offsets = const {},
  }) {
    final timezone = timezoneOffsetMinutes / 60.0;
    final julian = _julian(date);
    final decl = _sunDeclination(julian);
    final eqt = _equationOfTime(julian);

    final dhuhrTime = (12 + timezone) - (longitude / 15) - eqt;
    final sunriseTime =
        dhuhrTime - _hourAngle(0.833, latitude, decl); // 0.833 for refraction
    final sunsetTime = dhuhrTime + _hourAngle(0.833, latitude, decl);
    final fajrTime = dhuhrTime - _hourAngle(fajrAngle, latitude, decl);
    final ishaTime = dhuhrTime + _hourAngle(ishaAngle, latitude, decl);
    final asrTime = dhuhrTime + _asrHourAngle(latitude, decl, shadowFactor);
    final maghribTime = sunsetTime + (4 / 60); // +4 minutes after sunset

    DateTime _toDate(double time) {
      final hours = time.floor();
      final minutes = ((time - hours) * 60).floor();
      final seconds = (((time - hours) * 60) - minutes) * 60;
      return DateTime(
        date.year,
        date.month,
        date.day,
        hours,
        minutes,
        seconds.round(),
      );
    }

    DateTime applyOffset(String key, DateTime time) {
      final offset = offsets[key] ?? 0;
      return time.add(Duration(minutes: offset));
    }

    return PrayerTimes(
      fajr: applyOffset('fajr', _toDate(fajrTime)),
      sunrise: applyOffset('sunrise', _toDate(sunriseTime)),
      dhuhr: applyOffset('dhuhr', _toDate(dhuhrTime)),
      asr: applyOffset('asr', _toDate(asrTime)),
      maghrib: applyOffset('maghrib', _toDate(maghribTime)),
      isha: applyOffset('isha', _toDate(ishaTime)),
    );
  }

  double _julian(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
    return jd;
  }

  double _sunDeclination(double jd) {
    final d = jd - 2451545.0;
    final g = _radians(357.529 + 0.98560028 * d);
    final q = 280.459 + 0.98564736 * d;
    final l = _radians((q + 1.915 * sin(g) + 0.020 * sin(2 * g)) % 360);
    final e = _radians(23.439 - 0.00000036 * d);
    return asin(sin(e) * sin(l));
  }

  double _equationOfTime(double jd) {
    final d = jd - 2451545.0;
    final g = _radians(357.529 + 0.98560028 * d);
    final q = _radians((280.459 + 0.98564736 * d) % 360);
    final l = (q + _radians(1.915) * sin(g) + _radians(0.020) * sin(2 * g));
    final e = _radians(23.439 - 0.00000036 * d);
    final ra = atan2(cos(e) * sin(l), cos(l));
    final eqt = q - ra;
    return (_degrees(eqt) / 15.0);
  }

  double _hourAngle(double angle, double latitude, double decl) {
    final latRad = _radians(latitude);
    final angleRad = _radians(angle);
    final term = (cos(angleRad) - sin(latRad) * sin(decl)) /
        (cos(latRad) * cos(decl));
    final ha = acos(term.clamp(-1.0, 1.0));
    return _degrees(ha) / 15.0;
  }

  double _asrHourAngle(double latitude, double decl, double factor) {
    final latRad = _radians(latitude);
    final angle = atan(1 / (factor + tan(latRad - decl.abs())));
    return _degrees(angle) / 15.0;
  }

  double _radians(double degrees) => degrees * pi / 180.0;
  double _degrees(double radians) => radians * 180.0 / pi;
}
