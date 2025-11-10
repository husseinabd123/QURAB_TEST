import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
    _initialized = true;
  }

  /// Create notification channels
  static Future<void> _createNotificationChannels() async {
    // Adhan channel (High importance)
    const adhanChannel = AndroidNotificationChannel(
      AppConfig.adhanChannelId,
      AppConfig.adhanChannelName,
      description: AppConfig.adhanChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Reminders channel (Default importance)
    const remindersChannel = AndroidNotificationChannel(
      AppConfig.remindersChannelId,
      AppConfig.remindersChannelName,
      description: AppConfig.remindersChannelDesc,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    final plugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (plugin != null) {
      await plugin.createNotificationChannel(adhanChannel);
      await plugin.createNotificationChannel(remindersChannel);
    }
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Show Adhan notification
  static Future<void> showAdhanNotification({
    required String prayerName,
    required String time,
    String? soundPath,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConfig.adhanChannelId,
      AppConfig.adhanChannelName,
      channelDescription: AppConfig.adhanChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF8A9A5B),
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1000, // Adhan notification ID
      'حان وقت $prayerName',
      'الوقت: $time',
      notificationDetails,
      payload: 'adhan:$prayerName',
    );
  }

  /// Show hourly hadith notification
  static Future<void> showHadithNotification({
    required String hadith,
    required String source,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConfig.remindersChannelId,
      AppConfig.remindersChannelName,
      channelDescription: AppConfig.remindersChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2000 + DateTime.now().hour, // Unique ID per hour
      'حديث الساعة',
      hadith.length > 100 ? '${hadith.substring(0, 100)}...' : hadith,
      notificationDetails,
      payload: 'hadith:$source',
    );
  }

  /// Schedule notification at specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool isAdhan = false,
  }) async {
    final channelId = isAdhan 
        ? AppConfig.adhanChannelId 
        : AppConfig.remindersChannelId;
    final channelName = isAdhan 
        ? AppConfig.adhanChannelName 
        : AppConfig.remindersChannelName;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: isAdhan ? Importance.high : Importance.defaultImportance,
      priority: isAdhan ? Priority.high : Priority.defaultPriority,
      playSound: true,
      enableVibration: isAdhan,
      category: isAdhan ? AndroidNotificationCategory.alarm : null,
      fullScreenIntent: isAdhan,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Note: For exact alarms, we'll use android_alarm_manager_plus
    // This is a fallback for approximate scheduling
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
