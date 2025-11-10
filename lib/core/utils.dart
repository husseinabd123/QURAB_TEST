import 'package:intl/intl.dart';

class AppUtils {
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  static final DateFormat _weekFormatter = DateFormat('EEE d MMMM', 'ar');

  static String formatTime(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  static String formatWeekDate(DateTime dateTime) {
    return _weekFormatter.format(dateTime);
  }

  static String padSurahNumber(int number) {
    return number.toString().padLeft(3, '0');
  }

  static String sanitizeSearch(String input) {
    final normalized = input.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s]'), '');
    return normalized.trim();
  }

  static Duration secondsToDuration(int seconds) {
    return Duration(seconds: seconds);
  }
}
