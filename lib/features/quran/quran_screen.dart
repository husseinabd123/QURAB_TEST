import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
      ),
      body: Column(
        children: [
          _buildLastReadCard(context, ref),
          _buildQuickActions(context),
          Expanded(child: _buildSurahList(context, ref)),
        ],
      ),
    );
  }

  Widget _buildLastReadCard(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quranRepoProvider);
    final lastRead = repo.getLastReadPosition();

    if (lastRead == null) return const SizedBox.shrink();

    final surahNumber = lastRead['surah'] as int;
    final ayahNumber = lastRead['ayah'] as int;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/quran/reader/$surahNumber'),
        child: Row(
          children: [
            const Icon(Icons.bookmark, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'آخر قراءة',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سورة $surahNumber - آية $ayahNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite, size: 20),
              label: const Text('المفضلة'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark, size: 20),
              label: const Text('العلامات'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return surahsAsync.when(
      data: (surahs) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text('${surah.ayahCount} آية'),
                trailing: IconButton(
                  icon: Icon(
                    surah.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: surah.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await ref.read(quranRepoProvider).toggleSurahFavorite(surah.number);
                    ref.invalidate(surahListProvider);
                  },
                ),
                onTap: () => context.push('/quran/reader/${surah.number}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('حدث خطأ: $error'),
      ),
    );
  }
}
