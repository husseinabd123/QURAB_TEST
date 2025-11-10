import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../config.dart';
import 'notifications.dart';

class PermissionsHandler {
  static Future<bool> requestLocation({bool precise = false}) async {
    final permission =
        precise ? Permission.location : Permission.locationWhenInUse;
    final status = await permission.request();
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final manager = AndroidAlarmManager();
    try {
      final granted = await manager.canScheduleExactAlarms();
      if (granted) return true;
      await AndroidAlarmManager.requestExactAlarmsPermission();
      return await manager.canScheduleExactAlarms();
    } catch (e) {
      debugPrint('Exact alarm permission error: $e');
      return false;
    }
  }

  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.openSystemSettingsForExactAlarms();
  }

  static Future<void> openBatteryOptimizationSettings() async {
    await Workmanager().openBatteryOptimizationSettings();
  }

  static Future<void> ensureNotificationChannelSetup() async {
    await AppNotifications.ensureChannels();
  }

  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }
}
