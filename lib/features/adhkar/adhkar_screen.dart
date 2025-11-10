import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../config.dart';
import '../../data/models/dhikr.dart';
import '../../providers/app_providers.dart';

final _adhkarFilterProvider =
    StateProvider.autoDispose<String>((ref) => 'morning');

final _adhkarListProvider = FutureProvider<List<Dhikr>>((ref) {
  final repo = ref.watch(dhikrRepositoryProvider);
  return repo.getAll();
});

class AdhkarProgressController
    extends StateNotifier<Map<String, int>> {
  AdhkarProgressController(this._box)
      : super(_box.get('progress', defaultValue: <String, int>{})
            .cast<String, int>());

  final Box _box;

  void increment(String id, int repeat) {
    final current = state[id] ?? 0;
    final updated =
        Map<String, int>.from(state)..[id] = (current + 1).clamp(0, repeat);
    state = updated;
    _box.put('progress', updated);
  }

  void reset(String id) {
    final updated = Map<String, int>.from(state)..remove(id);
    state = updated;
    _box.put('progress', updated);
  }
}

final adhkarProgressProvider =
    StateNotifierProvider<AdhkarProgressController, Map<String, int>>((ref) {
  final box = Hive.box(AppConfig.adhkarProgressBox);
  return AdhkarProgressController(box);
});

class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_adhkarFilterProvider);
    final adhkarAsync = ref.watch(_adhkarListProvider);
    final progress = ref.watch(adhkarProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار اليومية'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ToggleButtons(
            isSelected: [
              filter == 'morning',
              filter == 'evening',
              filter == 'after_prayer',
              filter == 'any',
            ],
            onPressed: (index) {
              const keys = ['morning', 'evening', 'after_prayer', 'any'];
              ref.read(_adhkarFilterProvider.notifier).state = keys[index];
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('صباح'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('مساء'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('بعد الصلاة'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('عام'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: adhkarAsync.when(
              data: (list) {
                final filtered = filter == 'any'
                    ? list
                    : list
                        .where((dhikr) =>
                            dhikr.time == filter || dhikr.time == 'any')
                        .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('لا توجد أذكار متاحة'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dhikr = filtered[index];
                    final current = progress[dhikr.id] ?? 0;
                    final completed = current >= dhikr.repeat;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'التكرار: ${dhikr.repeat}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => ref
                                      .read(adhkarProgressProvider.notifier)
                                      .reset(dhikr.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dhikr.text,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: current / dhikr.repeat,
                              minHeight: 8,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('المنجز: $current'),
                                ElevatedButton(
                                  onPressed: completed
                                      ? null
                                      : () => ref
                                          .read(adhkarProgressProvider.notifier)
                                          .increment(dhikr.id, dhikr.repeat),
                                  child: Text(completed ? 'اكتمل' : 'تقدم'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
