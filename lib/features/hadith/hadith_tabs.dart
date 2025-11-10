import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/hadith.dart';
import '../../providers/app_providers.dart';

final _searchProvider = StateProvider.autoDispose<String>((ref) => '');

final hadithBySourceProvider =
    FutureProvider.family<List<Hadith>, String>((ref, source) async {
  final repo = ref.watch(hadithRepositoryProvider);
  if (source.contains('النبي')) {
    return repo.bySource('النبي');
  }
  if (source.contains('نهج')) {
    return repo.bySource('نهج البلاغة');
  }
  return repo.bySource('الإمام الحسين');
});

class HadithTabView extends ConsumerWidget {
  const HadithTabView({required this.source, super.key});

  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTerm = ref.watch(_searchProvider);
    final hadithAsync = ref.watch(hadithBySourceProvider(source));
    final repo = ref.watch(hadithRepositoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'ابحث في الأحاديث',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) => ref.read(_searchProvider.notifier).state = value,
          ),
        ),
        Expanded(
          child: hadithAsync.when(
            data: (hadiths) {
              final filtered = searchTerm.isEmpty
                  ? hadiths
                  : hadiths
                      .where((h) =>
                          h.text.contains(searchTerm) ||
                          h.tags.any((tag) => tag.contains(searchTerm)))
                      .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('لا توجد نتائج مطابقة'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) {
                  final hadith = filtered[index];
                  final isFav = repo.isFavorite(hadith.id);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  hadith.source,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () async {
                                  await repo.toggleFavorite(hadith.id);
                                  ref.invalidate(hadithBySourceProvider(source));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hadith.text,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (hadith.ref.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              hadith.ref,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => Share.share(hadith.text),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await FlutterClipboard.copy(hadith.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم النسخ')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: filtered.length,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('حدث خطأ: $error')),
          ),
        ),
      ],
    );
  }
}
