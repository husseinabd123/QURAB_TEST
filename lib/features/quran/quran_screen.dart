import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils.dart';
import '../../data/models/surah.dart';
import '../../providers/app_providers.dart';
import 'search_delegate.dart';

final surahIndexProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurahIndex();
});

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahIndexProvider);
    final repo = ref.watch(quranRepositoryProvider);
    final recents = repo.getRecents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final surahs = await surahsAsync.maybeWhen(
                data: (data) => data,
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
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            onPressed: () => context.push('/quran/surahs'),
          ),
        ],
      ),
      body: surahsAsync.when(
        data: (surahs) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (recents.isNotEmpty) ...[
                Text('تمت قراءتها مؤخرًا',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: recents
                      .map(
                        (number) => ActionChip(
                          label: Text('سورة ${surahs.firstWhere((s) => s.number == number).name}'),
                          onPressed: () =>
                              context.push('/quran/reader/$number'),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              _SectionCard(
                title: 'قراءة السور',
                icon: Icons.menu_book,
                subtitle: 'استعرض جميع السور مع البحث السريع والمفضلة',
                onTap: () => context.push('/quran/surahs'),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'استئناف آخر موضع',
                icon: Icons.play_arrow_rounded,
                subtitle: 'تابع آخر آية توقفت عندها بسهولة',
                onTap: () {
                  final lastSurah = recents.isNotEmpty ? recents.first : 1;
                  context.push('/quran/reader/$lastSurah');
                },
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'إدارة المفضلة',
                icon: Icons.bookmarks_outlined,
                subtitle: 'تحكم في العلامات المرجعية والسور المحمّلة مسبقًا',
                onTap: () => context.push('/quran/surahs'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(height: 12),
              Text('حدث خطأ غير متوقع: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(surahIndexProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
