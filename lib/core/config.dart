/// App-wide configuration constants
class AppConfig {
  AppConfig._();

  // App Identity
  static const String appName = 'حقيبة المؤمن+';
  static const String packageId = 'app.moemen.kit';
  
  // Recitation Base URL (placeholder - no bundled audio)
  static const String kRecitationBase = 'https://cdn.islamic-network.com/quran/audio/128/ar.alafasy';
  
  // Performance Targets
  static const Duration coldStartTarget = Duration(milliseconds: 1500);
  static const int targetFps = 60;
  static const int maxApkSizeMb = 60;
  
  // Cache Management
  static const int maxAudioCacheMb = 150;
  
  // Background Tasks
  static const String hourlyHadithTaskName = 'hourlyHadithReminder';
  static const String adhanTaskName = 'adhanScheduler';
  
  // Notification Channels
  static const String adhanChannelId = 'adhan_channel';
  static const String adhanChannelName = 'أذان';
  static const String adhanChannelDesc = 'إشعارات الأذان';
  
  static const String remindersChannelId = 'reminders';
  static const String remindersChannelName = 'تذكيرات';
  static const String remindersChannelDesc = 'تذكيرات الأحاديث والأذكار';
  
  // Prayer Calculation
  static const double fajrAngle = 16.0;
  static const double ishaAngle = 14.0;
  static const int maghribOffset = 4; // minutes after sunset
  
  // Debug
  static const bool enableDebugMode = false;
}
