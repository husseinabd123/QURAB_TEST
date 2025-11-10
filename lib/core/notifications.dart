import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../config.dart';

class AppNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification clicked: ${response.id} ${response.payload}');
      },
    );

    await ensureChannels();
    _initialized = true;
  }

  static Future<void> ensureChannels() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    await androidImpl.createNotificationChannel(const AndroidNotificationChannel(
      AppConfig.adhanNotificationChannelId,
      AppConfig.adhanNotificationChannelName,
      description: 'تنبيهات الأذان وتشغيل الصوت في الخلفية',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ));

    await androidImpl.createNotificationChannel(const AndroidNotificationChannel(
      AppConfig.reminderChannelId,
      AppConfig.reminderChannelName,
      description: 'تذكير الأحاديث اليومية والتنبيهات العامة',
      importance: Importance.high,
      playSound: true,
    ));
  }

  static Future<void> scheduleAdhan({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String assetSound,
    String? payload,
  }) async {
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.adhanNotificationChannelId,
          AppConfig.adhanNotificationChannelName,
          channelDescription: 'تنبيهات الأذان وتشغيل الصوت',
          priority: Priority.max,
          importance: Importance.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          ticker: 'أذان',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleHourlyHadith({
    required int id,
    required DateTime dateTime,
    required String hadith,
  }) async {
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      'تذكير إيماني',
      hadith,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.reminderChannelId,
          AppConfig.reminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ذكر جديد',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.reminderChannelId,
          AppConfig.reminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static Future<void> cancelByTag(String tag) async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.cancel(tag.hashCode);
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
