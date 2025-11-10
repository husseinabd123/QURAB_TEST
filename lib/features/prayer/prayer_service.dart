import 'dart:math' as math;
import '../../core/config.dart';
import '../../data/models/prayer_settings.dart';

class PrayerService {
  /// Calculate prayer times using Ja'fari method
  static PrayerTimes calculatePrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
    Map<String, int> offsets,
  ) {
    final julianDate = _calculateJulianDate(date);
    final equation = _calculateEquationOfTime(julianDate);
    final declination = _calculateSunDeclination(julianDate);
    
    // Calculate times
    final fajr = _calculatePrayerTime(latitude, longitude, date, declination, equation, AppConfig.fajrAngle, false);
    final sunrise = _calculatePrayerTime(latitude, longitude, date, declination, equation, 0.833, false);
    final dhuhr = _calculateNoon(longitude, date, equation);
    final asr = _calculateAsr(latitude, longitude, date, declination, equation, 1); // Shadow factor = 1 for Ja'fari
    final maghrib = _calculatePrayerTime(latitude, longitude, date, declination, equation, 0.833, true).add(Duration(minutes: AppConfig.maghribOffset));
    final isha = _calculatePrayerTime(latitude, longitude, date, declination, equation, AppConfig.ishaAngle, true);

    // Apply offsets
    return PrayerTimes(
      fajr: fajr.add(Duration(minutes: offsets['fajr'] ?? 0)),
      sunrise: sunrise.add(Duration(minutes: offsets['sunrise'] ?? 0)),
      dhuhr: dhuhr.add(Duration(minutes: offsets['dhuhr'] ?? 0)),
      asr: asr.add(Duration(minutes: offsets['asr'] ?? 0)),
      maghrib: maghrib.add(Duration(minutes: offsets['maghrib'] ?? 0)),
      isha: isha.add(Duration(minutes: offsets['isha'] ?? 0)),
    );
  }

  static double _calculateJulianDate(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day + (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;
    
    var a = ((14 - month) / 12).floor();
    var y = year + 4800 - a;
    var m = month + 12 * a - 3;
    
    return day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
  }

  static double _calculateEquationOfTime(double jd) {
    final d = jd - 2451545.0;
    final g = 357.529 + 0.98560028 * d;
    final q = 280.459 + 0.98564736 * d;
    final l = q + 1.915 * _sin(g) + 0.020 * _sin(2 * g);
    final e = 23.439 - 0.00000036 * d;
    final ra = _atan2(_cos(e) * _sin(l), _cos(l)) / 15;
    final eqt = q / 15 - ra;
    
    return eqt;
  }

  static double _calculateSunDeclination(double jd) {
    final d = jd - 2451545.0;
    final g = 357.529 + 0.98560028 * d;
    final q = 280.459 + 0.98564736 * d;
    final l = q + 1.915 * _sin(g) + 0.020 * _sin(2 * g);
    final e = 23.439 - 0.00000036 * d;
    
    return _asin(_sin(e) * _sin(l));
  }

  static DateTime _calculatePrayerTime(
    double latitude,
    double longitude,
    DateTime date,
    double declination,
    double equation,
    double angle,
    bool isSunset,
  ) {
    final cosH = (_cos(90 + angle) - _sin(declination) * _sin(latitude)) / (_cos(declination) * _cos(latitude));
    
    if (cosH > 1 || cosH < -1) {
      // Sun never rises or sets at this location
      return date;
    }
    
    final h = _acos(cosH) / 15;
    final t = 12 + (isSunset ? h : -h) - longitude / 15 - equation;
    
    final hour = t.floor();
    final minute = ((t - hour) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static DateTime _calculateNoon(double longitude, DateTime date, double equation) {
    final t = 12 - longitude / 15 - equation;
    final hour = t.floor();
    final minute = ((t - hour) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static DateTime _calculateAsr(
    double latitude,
    double longitude,
    DateTime date,
    double declination,
    double equation,
    int shadowFactor,
  ) {
    final angle = -_atan(1 / (shadowFactor + _tan(latitude - declination)));
    final cosH = (_sin(angle) - _sin(declination) * _sin(latitude)) / (_cos(declination) * _cos(latitude));
    
    if (cosH > 1 || cosH < -1) {
      return date;
    }
    
    final h = _acos(cosH) / 15;
    final t = 12 + h - longitude / 15 - equation;
    
    final hour = t.floor();
    final minute = ((t - hour) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Helper trig functions (degrees)
  static double _sin(double degrees) => math.sin(degrees * math.pi / 180);
  static double _cos(double degrees) => math.cos(degrees * math.pi / 180);
  static double _tan(double degrees) => math.tan(degrees * math.pi / 180);
  static double _asin(double value) => math.asin(value) * 180 / math.pi;
  static double _acos(double value) => math.acos(value) * 180 / math.pi;
  static double _atan(double value) => math.atan(value) * 180 / math.pi;
  static double _atan2(double y, double x) => math.atan2(y, x) * 180 / math.pi;
}
