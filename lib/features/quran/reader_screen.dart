import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/surah.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;

  const ReaderScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  double _fontSize = 24.0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(quranRepoProvider);
    final surah = repo.getSurahByNumber(widget.surahNumber);

    if (surah == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('القرآن الكريم')),
        body: const Center(child: Text('السورة غير موجودة')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize + 2).clamp(16.0, 36.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 2).clamp(16.0, 36.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSurahHeader(surah),
          Expanded(child: _buildAyahList(surah)),
          _buildAudioControls(),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(Surah surah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${surah.ayahCount} آية • ${surah.revelationType == "Meccan" ? "مكية" : "مدنية"}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (surah.number != 1 && surah.number != 9)
            Text(
              'بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontSize: _fontSize + 4,
                height: 2.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildAyahList(Surah surah) {
    // Placeholder: Generate sample ayahs
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surah.ayahCount,
      itemBuilder: (context, index) {
        final ayahNumber = index + 1;
        return _buildAyahCard(ayahNumber, surah);
      },
    );
  }

  Widget _buildAyahCard(int ayahNumber, Surah surah) {
    final repo = ref.watch(quranRepoProvider);
    final isBookmarked = repo.isAyahBookmarked(surah.number, ayahNumber);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$ayahNumber',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                      ),
                      onPressed: () async {
                        await repo.toggleAyahBookmark(surah.number, ayahNumber);
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                        // Share ayah
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        // Copy ayah
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'نَصّ الآية رقم $ayahNumber من سورة ${surah.name} (نص تجريبي)',
              style: TextStyle(
                fontSize: _fontSize,
                height: 2.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: 0.0,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                iconSize: 48,
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ملاحظة: التلاوة تعمل عبر الإنترنت فقط (Streaming)',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('تحميل التلاوة'),
                onTap: () {
                  Navigator.pop(context);
                  // Download audio
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('معلومات السورة'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
