import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/dhikr.dart';

class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الصباح'),
            Tab(text: 'المساء'),
            Tab(text: 'بعد الصلاة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdhkarList('morning'),
          _buildAdhkarList('evening'),
          _buildAdhkarList('after_prayer'),
        ],
      ),
    );
  }

  Widget _buildAdhkarList(String timeFilter) {
    final adhkarAsync = ref.watch(adhkarListProvider);

    return adhkarAsync.when(
      data: (adhkar) {
        final filteredAdhkar = adhkar.where((d) => d.time == timeFilter).toList();

        if (filteredAdhkar.isEmpty) {
          return const Center(
            child: Text('لا توجد أذكار'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAdhkar.length,
          itemBuilder: (context, index) {
            return _buildDhikrCard(filteredAdhkar[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
    );
  }

  Widget _buildDhikrCard(Dhikr dhikr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dhikr.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 2.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
            if (dhikr.reference != null) ...[
              const SizedBox(height: 12),
              Text(
                dhikr.reference!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: dhikr.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: dhikr.isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dhikr.currentCount} / ${dhikr.repeatCount}',
                    style: TextStyle(
                      color: dhikr.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (dhikr.currentCount > 0)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(dhikrRepoProvider).decrementCount(dhikr.id);
                      ref.invalidate(adhkarListProvider);
                    },
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('تراجع'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: dhikr.isCompleted
                      ? null
                      : () async {
                          await ref.read(dhikrRepoProvider).incrementCount(dhikr.id);
                          ref.invalidate(adhkarListProvider);
                        },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('تسبيح'),
                ),
                const SizedBox(width: 8),
                if (dhikr.currentCount > 0)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await ref.read(dhikrRepoProvider).resetCount(dhikr.id);
                      ref.invalidate(adhkarListProvider);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
