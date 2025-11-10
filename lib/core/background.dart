import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import '../config.dart';
import '../data/models/hadith.dart';
import 'notifications.dart';

class BackgroundDispatcher {
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      switch (taskName) {
        case AppConfig.hourlyHadithTask:
          await _handleHourlyHadith();
          return true;
        default:
          return false;
      }
    });
  }

  static Future<void> registerHourlyHadithTask() {
    return Workmanager().registerPeriodicTask(
      AppConfig.hourlyHadithTask,
      AppConfig.hourlyHadithTask,
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: const Duration(minutes: 5),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
      ),
    );
  }

  static Future<void> cancelHourlyHadithTask() {
    return Workmanager().cancelByUniqueName(AppConfig.hourlyHadithTask);
  }

  static Future<void> _handleHourlyHadith() async {
    final bundle = rootBundle;
    final raw = await bundle.loadString('assets/json/hadith.json');
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((json) => Hadith.fromJson(json as Map<String, dynamic>))
        .toList();
    if (list.isEmpty) return;

    final now = DateTime.now();
    final rand = Random(now.millisecondsSinceEpoch);
    final hadith = list[rand.nextInt(list.length)];

    await AppNotifications.initialize();
    await AppNotifications.showInstant(
      id: now.millisecondsSinceEpoch.remainder(100000),
      title: 'حديث الساعة',
      body: hadith.text,
      payload: hadith.id,
    );
  }
}
