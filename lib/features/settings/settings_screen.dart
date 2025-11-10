import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config.dart';
import '../../core/background.dart';
import '../../core/permissions.dart';
import '../../core/notifications.dart';
import '../../data/models/prayer_settings.dart';
import '../../providers/app_providers.dart';
import '../quran/download_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: ListView(
          children: [
            _ThemeSection(settings: settings),
            const Divider(),
            _NotificationsSection(settings: settings),
            const Divider(),
            _AudioCacheSection(settings: settings),
            const Divider(),
            _BackupSection(settings: settings),
            const Divider(),
            const _DebugSection(),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المظهر واللغة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: settings.themeMode,
            decoration: const InputDecoration(
              label: Text('اختيار المظهر'),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('حسب النظام')),
              DropdownMenuItem(value: 'light', child: Text('فاتح')),
              DropdownMenuItem(value: 'dark', child: Text('داكن')),
            ],
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(settingsControllerProvider.notifier)
                  .update(settings.copyWith(themeMode: value));
            },
          ),
          const SizedBox(height: 12),
          Slider(
            value: settings.fontScale,
            min: 0.9,
            max: 1.4,
            divisions: 5,
            label: settings.fontScale.toStringAsFixed(1),
            onChanged: (scale) => ref
                .read(settingsControllerProvider.notifier)
                .updateFontScale(scale),
          ),
          const SizedBox(height: 12),
          Text(
            'اللغة: العربية (افتراضي)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإشعارات', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            value: settings.adhanEnabled,
            title: const Text('إشعارات الأذان'),
            onChanged: (value) {
              ref.read(settingsControllerProvider.notifier).toggleAdhan(value);
              if (value) PermissionsHandler.requestNotification();
            },
          ),
          SwitchListTile(
            value: settings.hourlyHadithEnabled,
            title: const Text('تذكير حديث كل ساعة'),
            onChanged: (value) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .toggleHourlyHadith(value);
              if (value) {
                BackgroundDispatcher.registerHourlyHadithTask();
              } else {
                BackgroundDispatcher.cancelHourlyHadithTask();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_saver),
            title: const Text('استثناء البطارية'),
            subtitle: const Text('لضمان عمل الأذان وحديث الساعة في الخلفية'),
            onTap: PermissionsHandler.openBatteryOptimizationSettings,
          ),
          ListTile(
            leading: const Icon(Icons.alarm_on),
            title: const Text('سماح الجداول الدقيقة'),
            onTap: PermissionsHandler.openExactAlarmSettings,
          ),
        ],
      ),
    );
  }
}

class _AudioCacheSection extends ConsumerWidget {
  const _AudioCacheSection({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التخزين الصوتي', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.audioCacheEnabled,
            title: const Text('تفعيل التخزين المؤقت للتلاوات'),
            onChanged: (value) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .update(settings.copyWith(audioCacheEnabled: value));
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('مسح التخزين المؤقت'),
            onTap: () async {
              final manager = ref.read(quranDownloadManagerProvider);
              await manager.clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إفراغ التخزين المؤقت')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BackupSection extends ConsumerWidget {
  const _BackupSection({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('النسخ الاحتياطي', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('تصدير الإعدادات والمفضلة'),
            onTap: () async {
              final controller = ref.read(settingsControllerProvider.notifier);
              final settingsData =
                  controller.state.value ?? PrayerSettings.defaults();
              final boxHadith = ref.watch(hadithRepositoryProvider);
              final hadithFavs = Hive.box(AppConfig.hadithFavoritesBox)
                  .get('ids', defaultValue: <String>[]);
              final data = jsonEncode({
                'settings': settingsData.toJson(),
                'hadith_favorites': hadithFavs,
              });
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/backup.json');
              await file.writeAsString(data);
              await Share.shareXFiles([XFile(file.path)],
                  text: 'نسخة احتياطية من حقيبة المؤمن+');
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('استيراد ملف نسخ احتياطي'),
            subtitle: const Text('ضع ملف backup.json في مجلد التنزيلات'),
            onTap: () async {
              final dir = await getDownloadsDirectory();
              if (dir == null) return;
              final file = File('${dir.path}/backup.json');
              if (!await file.exists()) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لم يتم العثور على الملف')),
                  );
                }
                return;
              }
              final json = jsonDecode(await file.readAsString())
                  as Map<String, dynamic>;
              final controller = ref.read(settingsControllerProvider.notifier);
              controller.update(PrayerSettings.fromJson(json['settings']));
              Hive.box(AppConfig.hadithFavoritesBox)
                  .put('ids', json['hadith_favorites']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الاستيراد بنجاح')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DebugSection extends StatelessWidget {
  const _DebugSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أدوات الاختبار', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('تجربة إشعار الأذان'),
            onTap: () async {
              final now = DateTime.now().add(const Duration(seconds: 5));
              await AppNotifications.scheduleAdhan(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                dateTime: now,
                title: 'تنبيه اختبار',
                body: 'سيعمل الأذان بعد ثوانٍ معدودة.',
                assetSound: 'adhan1',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('تشغيل حديث الساعة الآن'),
            onTap: () => BackgroundDispatcher.registerHourlyHadithTask(),
          ),
        ],
      ),
    );
  }
}
