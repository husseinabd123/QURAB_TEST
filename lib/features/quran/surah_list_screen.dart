import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils.dart';
import '../../data/models/surah.dart';
import '../../providers/app_providers.dart';
import 'bookmarks_controller.dart';
import 'quran_screen.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahIndexProvider);
    final bookmarksAsync = ref.watch(quranBookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة السور'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final surahs = await surahAsync.maybeWhen(
                data: (value) => value,
                orElse: () => <Surah>[],
              );
              if (surahs.isEmpty) return;
              // ignore: use_build_context_synchronously
              showSearch(
                context: context,
                delegate: QuranSearchDelegate(
                  surahs: surahs,
                  onSelected: (surah) {
                    context.push('/quran/reader/${surah.number}');
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: surahAsync.when(
        data: (surahs) {
          final filtered = _filterSurahs(surahs, _query);
          final bookmarks = bookmarksAsync.maybeWhen(
            data: (value) => value
                .map((item) => '${item['surah']}:${item['ayah']}')
                .toSet(),
            orElse: () => <String>{},
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'ابحث باسم السورة أو رقمها',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    final bookmarkKey = '${surah.number}:${surah.ayahCount}';
                    final isBookmarked = bookmarks.contains(bookmarkKey);

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(AppUtils.padSurahNumber(surah.number)),
                      ),
                      title: Text(surah.name),
                      subtitle: Text('عدد الآيات: ${surah.ayahCount}'),
                      trailing: IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        onPressed: () => ref
                            .read(quranBookmarksProvider.notifier)
                            .toggle(surah.number, surah.ayahCount),
                      ),
                      onTap: () => context.push('/quran/reader/${surah.number}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('حدث خطأ: $error'),
        ),
      ),
    );
  }

  List<Surah> _filterSurahs(List<Surah> surahs, String query) {
    if (query.isEmpty) return surahs;
    final normalized = query.trim();
    return surahs.where((surah) {
      final numberMatch = surah.number.toString().contains(normalized);
      final nameMatch = surah.name.contains(normalized);
      return numberMatch || nameMatch;
    }).toList();
  }
}
