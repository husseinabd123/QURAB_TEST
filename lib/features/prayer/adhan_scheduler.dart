import '../../config.dart';
import '../../core/notifications.dart';
import '../../data/models/prayer_settings.dart';
import 'prayer_service.dart';

class AdhanScheduler {
  Future<void> scheduleDay(
    PrayerTimes times,
    PrayerSettings settings,
  ) async {
    if (!settings.adhanEnabled) {
      await AppNotifications.cancelByTag(AppConfig.adhanWorkTag);
      return;
    }

    await AppNotifications.scheduleAdhan(
      id: _idFor('fajr'),
      dateTime: times.fajr,
      title: 'حان وقت صلاة الفجر',
      body: 'آن أوان الأذان لصلاة الفجر.',
      assetSound: settings.adhanSoundAsset,
      payload: 'fajr',
    );
    await AppNotifications.scheduleAdhan(
      id: _idFor('dhuhr'),
      dateTime: times.dhuhr,
      title: 'حان وقت صلاة الظهر',
      body: 'آن أوان الأذان لصلاة الظهر.',
      assetSound: settings.adhanSoundAsset,
      payload: 'dhuhr',
    );
    await AppNotifications.scheduleAdhan(
      id: _idFor('asr'),
      dateTime: times.asr,
      title: 'حان وقت صلاة العصر',
      body: 'آن أوان الأذان لصلاة العصر.',
      assetSound: settings.adhanSoundAsset,
      payload: 'asr',
    );
    await AppNotifications.scheduleAdhan(
      id: _idFor('maghrib'),
      dateTime: times.maghrib,
      title: 'حان وقت صلاة المغرب',
      body: 'آن أوان الأذان لصلاة المغرب.',
      assetSound: settings.adhanSoundAsset,
      payload: 'maghrib',
    );
    await AppNotifications.scheduleAdhan(
      id: _idFor('isha'),
      dateTime: times.isha,
      title: 'حان وقت صلاة العشاء',
      body: 'آن أوان الأذان لصلاة العشاء.',
      assetSound: settings.adhanSoundAsset,
      payload: 'isha',
    );
  }

  Future<void> cancelAll() async {
    await AppNotifications.cancel(_idFor('fajr'));
    await AppNotifications.cancel(_idFor('dhuhr'));
    await AppNotifications.cancel(_idFor('asr'));
    await AppNotifications.cancel(_idFor('maghrib'));
    await AppNotifications.cancel(_idFor('isha'));
  }

  int _idFor(String prayer) => prayer.hashCode & 0x7FFFFFFF;
}
