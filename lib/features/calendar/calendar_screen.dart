import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../providers/app_providers.dart';

final _dateFormat = DateFormat('EEEE d MMMM yyyy', 'ar');

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return settings.when(
      data: (value) {
        final today = DateTime.now();
        final hijri = HijriCalendar.now()
          ..hijriOffset = value.hijriOffset
          ..setDate(today.year, today.month, today.day);

        final events = _buildEventsList(today.year);

        return Scaffold(
          appBar: AppBar(
            title: const Text('التقويم الهجري/الميلادي'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_backup_restore),
                onPressed: () {
                  final controller = ref.read(settingsControllerProvider.notifier);
                  controller.update(
                    value.copyWith(hijriOffset: 0),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اليوم',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(_dateFormat.format(today)),
                      Text(
                        '${hijri.getDayName()} ${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text('تصحيح التقويم: ${value.hijriOffset} يوم'),
                      Slider(
                        value: value.hijriOffset.toDouble(),
                        min: -2,
                        max: 2,
                        divisions: 4,
                        label: '${value.hijriOffset}',
                        onChanged: (offset) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .update(value.copyWith(hijriOffset: offset.toInt()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'أحداث هذا الشهر',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...events.map(
                        (event) => ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(event.title),
                          subtitle: Text(event.description),
                          trailing: Text(event.hijriDate),
                        ),
                      ),
                    ],
                  ),
                ),
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

  List<_CalendarEvent> _buildEventsList(int gregorianYear) {
    return [
      _CalendarEvent(
        title: 'ولادة الإمام علي (ع)',
        description: '13 رجب',
        hijriDate: '13 رجب ${gregorianYear + 579 - 2024} هـ',
      ),
      _CalendarEvent(
        title: 'شعبان المعظم',
        description: 'ليالي ذكرى مولد الإمام الحجة (عج)',
        hijriDate: '15 شعبان',
      ),
      _CalendarEvent(
        title: 'شهر رمضان المبارك',
        description: 'بداية شهر الصيام',
        hijriDate: '1 رمضان',
      ),
      _CalendarEvent(
        title: 'يوم عاشوراء',
        description: 'ذكرى شهادة الإمام الحسين (ع)',
        hijriDate: '10 محرم',
      ),
    ];
  }
}

class _CalendarEvent {
  final String title;
  final String description;
  final String hijriDate;

  const _CalendarEvent({
    required this.title,
    required this.description,
    required this.hijriDate,
  });
}
