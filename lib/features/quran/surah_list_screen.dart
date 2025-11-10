import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  @override
  Widget build(BuildContext context) {
    final surahs = ref.watch(filteredSurahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة السور'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                ref.read(quranSearchQueryProvider.notifier).state = value;
              },
              decoration: const InputDecoration(
                hintText: 'البحث عن سورة...',
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${surah.number}'),
              ),
              title: Text(surah.name),
              subtitle: Text('${surah.ayahCount} آية'),
              onTap: () => context.push('/quran/reader/${surah.number}'),
            ),
          );
        },
      ),
    );
  }
}
