import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/app_providers.dart';

final _duaSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final _duaListProvider = FutureProvider(
  (ref) => ref.watch(duaRepositoryProvider).getAll(),
);

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(_duaSearchProvider);
    final duasAsync = ref.watch(_duaListProvider);
    final repo = ref.watch(duaRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدعية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن دعاء',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) => ref.read(_duaSearchProvider.notifier).state =
                  value.trim(),
            ),
          ),
          Expanded(
            child: duasAsync.when(
              data: (duas) {
                final filtered = search.isEmpty
                    ? duas
                    : duas
                        .where((dua) =>
                            dua.title.contains(search) ||
                            dua.text.contains(search))
                        .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('لا توجد أدعية مطابقة'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final dua = filtered[index];
                    final isFav = repo.isFavorite(dua.id);
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
                              children: [
                                Expanded(
                                  child: Text(
                                    dua.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  onPressed: () async {
                                    await repo.toggleFavorite(dua.id);
                                    ref.invalidate(_duaListProvider);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dua.text,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => Share.share(dua.text),
                                  icon: const Icon(Icons.share),
                                  label: const Text('مشاركة'),
                                ),
                                const SizedBox(width: 12),
                                TextButton.icon(
                                  onPressed: () async {
                                    await FlutterClipboard.copy(dua.text);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ الدعاء'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('نسخ'),
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
