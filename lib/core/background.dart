import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications.dart';
import 'config.dart';

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case AppConfig.hourlyHadithTaskName:
          await _sendHourlyHadith();
          break;
        default:
          break;
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

/// Send hourly hadith notification
Future<void> _sendHourlyHadith() async {
  await NotificationService.initialize();
  
  // Get random hadith from simple list
  final hadiths = [
    {'text': 'قال رسول الله (ص): خيركم من تعلم القرآن وعلمه', 'source': 'النبي (ص)'},
    {'text': 'قال الإمام علي (ع): العلم خير من المال', 'source': 'نهج البلاغة'},
    {'text': 'قال الإمام الحسين (ع): الناس عبيد الدنيا والدين لعق على ألسنتهم', 'source': 'الإمام الحسين (ع)'},
    {'text': 'قال رسول الله (ص): المؤمن مرآة المؤمن', 'source': 'النبي (ص)'},
    {'text': 'قال الإمام علي (ع): النفس كالزجاجة والعلم كالسراج', 'source': 'نهج البلاغة'},
  ];
  
  final random = Random();
  final hadith = hadiths[random.nextInt(hadiths.length)];
  
  await NotificationService.showHadithNotification(
    hadith: hadith['text']!,
    source: hadith['source']!,
  );
}

class BackgroundService {
  /// Initialize background services
  static Future<void> initialize() async {
    // Initialize WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: AppConfig.enableDebugMode,
    );

    // Initialize Android Alarm Manager
    await AndroidAlarmManager.initialize();
  }

  /// Register hourly hadith task
  static Future<void> registerHourlyHadithTask() async {
    await Workmanager().registerPeriodicTask(
      AppConfig.hourlyHadithTaskName,
      AppConfig.hourlyHadithTaskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Cancel hourly hadith task
  static Future<void> cancelHourlyHadithTask() async {
    await Workmanager().cancelByUniqueName(AppConfig.hourlyHadithTaskName);
  }

  /// Schedule exact alarm for Adhan
  static Future<void> scheduleAdhanAlarm({
    required int id,
    required DateTime time,
    required String prayerName,
  }) async {
    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      _adhanAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {'prayerName': prayerName, 'time': time.toIso8601String()},
    );
  }

  /// Adhan alarm callback
  @pragma('vm:entry-point')
  static Future<void> _adhanAlarmCallback(int id, Map<String, dynamic>? params) async {
    await NotificationService.initialize();
    
    final prayerName = params?['prayerName'] as String? ?? 'الصلاة';
    final timeStr = params?['time'] as String?;
    final time = timeStr != null ? DateTime.parse(timeStr) : DateTime.now();
    
    await NotificationService.showAdhanNotification(
      prayerName: prayerName,
      time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  /// Cancel specific adhan alarm
  static Future<void> cancelAdhanAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }

  /// Cancel all adhan alarms
  static Future<void> cancelAllAdhanAlarms() async {
    // Prayer IDs: 0=Fajr, 1=Dhuhr, 2=Asr, 3=Maghrib, 4=Isha
    for (int i = 0; i < 5; i++) {
      await AndroidAlarmManager.cancel(i);
    }
  }

  /// Check if hourly hadith is enabled
  static Future<bool> isHourlyHadithEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hourly_hadith_enabled') ?? false;
  }

  /// Enable/disable hourly hadith
  static Future<void> setHourlyHadithEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hourly_hadith_enabled', enabled);
    
    if (enabled) {
      await registerHourlyHadithTask();
    } else {
      await cancelHourlyHadithTask();
    }
  }
}
