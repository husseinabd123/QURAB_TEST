import 'dart:ui';

class AppConfig {
  static const appName = 'حقيبة المؤمن+';
  static const packageName = 'app.moemen.kit';
  static const minApiLevel = 24;
  static const targetApiLevel = 35;

  static const kRecitationBase =
      'https://example.com/recitations/{surah}.mp3'; // يتم استبدال {surah} برقم السورة بصيغة ثلاثية (001)

  static const quranBookmarksBox = 'quran_bookmarks';
  static const quranRecentsBox = 'quran_recents';
  static const hadithFavoritesBox = 'hadith_favorites';
  static const duaFavoritesBox = 'dua_favorites';
  static const adhkarProgressBox = 'adhkar_progress';
  static const tasbihBox = 'tasbih_prefs';
  static const settingsBox = 'app_settings';
  static const cacheInfoBox = 'cache_info';

  static const audioCacheLimitBytes = 150 * 1024 * 1024; // 150MB

  static const adhanNotificationChannelId = 'adhan_channel';
  static const adhanNotificationChannelName = 'إشعارات الأذان';
  static const reminderChannelId = 'reminders';
  static const reminderChannelName = 'تذكيرات عامة';

  static const hourlyHadithTask = 'hourly_hadith_task';
  static const adhanWorkTag = 'adhan_schedule';

  static const defaultLocale = Locale('ar');
}
