import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/permissions.dart';
import '../../core/utils.dart';
import '../../data/models/prayer_settings.dart';
import '../../providers/app_providers.dart';
import 'adhan_scheduler.dart';
import 'governorates.dart';
import 'offsets_controller.dart';
import 'prayer_service.dart';

final _calculator = JafariPrayerCalculator();

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) {
        final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes +
            settings.hijriOffset * 60;
        final times = _calculator.calculate(
          date: DateTime.now(),
          latitude: settings.latitude,
          longitude: settings.longitude,
          timezoneOffsetMinutes: timezoneOffset,
          offsets: settings.offsets,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('مواقيت الصلاة'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LocationCard(settings: settings),
              const SizedBox(height: 16),
              _PrayerTimesCard(times: times),
              const SizedBox(height: 16),
              _OffsetEditor(settings: settings),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final scheduler = AdhanScheduler();
                  await scheduler.scheduleDay(times, settings);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث جداول الأذان')),
                    );
                  }
                },
                icon: const Icon(Icons.alarm),
                label: const Text('تحديث جداول الأذان'),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }
}

class _LocationCard extends ConsumerWidget {
  const _LocationCard({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الموقع الحالي',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '${settings.governorate} - ${settings.city}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'خط العرض: ${settings.latitude.toStringAsFixed(4)}, خط الطول: ${settings.longitude.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectManualLocation(context, ref),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('اختيار يدوي'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _detectLocation(ref, context),
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('تحديد تلقائي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectManualLocation(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: iraqGovernorates.length,
          itemBuilder: (context, index) {
            final governorate = iraqGovernorates[index];
            return ExpansionTile(
              title: Text(governorate.name),
              children: governorate.cities
                  .map(
                    (city) => ListTile(
                      title: Text(city.name),
                      onTap: () {
                        final current =
                            controller.state.value ?? PrayerSettings.defaults();
                        controller.update(
                          current.copyWith(
                            governorate: governorate.name,
                            city: city.name,
                            latitude: city.latitude,
                            longitude: city.longitude,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }

  Future<void> _detectLocation(WidgetRef ref, BuildContext context) async {
    final granted = await PermissionsHandler.requestLocation(precise: true);
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء منح إذن الموقع')),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final controller = ref.read(settingsControllerProvider.notifier);
    final current = controller.state.value ?? PrayerSettings.defaults();
    controller.update(
      current.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'موقع GPS',
        governorate: 'موقع مخصص',
      ),
    );
  }
}

class _PrayerTimesCard extends StatelessWidget {
  const _PrayerTimesCard({required this.times});

  final PrayerTimes times;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أوقات الصلاة لليوم',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...times.asEntries().map(
                  (entry) => ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(entry.key),
                    trailing: Text(AppUtils.formatTime(entry.value)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _OffsetEditor extends ConsumerWidget {
  const _OffsetEditor({required this.settings});

  final PrayerSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offsets = ref.watch(prayerOffsetProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الفروق الزمنية (دقائق)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...offsets.entries.map(
              (entry) => Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => ref
                        .read(prayerOffsetProvider.notifier)
                        .updateOffset(entry.key, entry.value - 1),
                  ),
                  Text('${entry.value}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => ref
                        .read(prayerOffsetProvider.notifier)
                        .updateOffset(entry.key, entry.value + 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
