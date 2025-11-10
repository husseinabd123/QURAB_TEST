import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils.dart';
import '../../data/models/surah.dart';
import '../../providers/app_providers.dart';
import 'bookmarks_controller.dart';
import 'audio_controller.dart';

final surahReaderProvider =
    FutureProvider.family<Surah, int>((ref, surahNumber) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurah(surahNumber);
});

final _pageModeProvider = StateProvider.autoDispose<bool>((ref) => true);

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.surahNumber, super.key});

  final int surahNumber;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _prepareAudio());
  }

  Future<void> _prepareAudio() async {
    final controller = ref.read(quranAudioControllerProvider.notifier);
    final surah =
        await ref.read(surahReaderProvider(widget.surahNumber).future);
    await controller.loadSurah(surah);
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahReaderProvider(widget.surahNumber));
    final audioState = ref.watch(quranAudioControllerProvider);
    final controller = ref.read(quranAudioControllerProvider.notifier);
    final pageMode = ref.watch(_pageModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة رقم ${widget.surahNumber}'),
        actions: [
          IconButton(
            icon: Icon(pageMode ? Icons.view_stream : Icons.view_day),
            tooltip: pageMode ? 'وضع الآيات' : 'وضع الصفحات',
            onPressed: () =>
                ref.read(_pageModeProvider.notifier).state = !pageMode,
          ),
        ],
      ),
      body: surahAsync.when(
        data: (surah) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surah.ayat.length,
                  itemBuilder: (context, index) {
                    final ayah = surah.ayat[index];
                    final isCurrent = audioState.currentAyah == ayah.number;
                    return AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'آية ${ayah.number}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () => ref
                                    .read(quranBookmarksProvider.notifier)
                                    .toggle(surah.number, ayah.number),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah.text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _ReaderControls(
                surah: surah,
                audioState: audioState,
                controller: controller,
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
              const SizedBox(height: 8),
              Text('تعذر تحميل السورة: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(surahReaderProvider(widget.surahNumber)),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({
    required this.surah,
    required this.audioState,
    required this.controller,
  });

  final Surah surah;
  final QuranAudioState audioState;
  final QuranAudioController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الموضع الحالي: ${audioState.position.inMinutes}:${(audioState.position.inSeconds % 60).toString().padLeft(2, '0')}'),
                Text(
                    'المدة: ${audioState.duration.inMinutes}:${(audioState.duration.inSeconds % 60).toString().padLeft(2, '0')}'),
              ],
            ),
            Slider(
              value: audioState.position.inSeconds.toDouble(),
              max: audioState.duration.inSeconds.toDouble().clamp(1, 10000),
              onChanged: (value) =>
                  controller.seek(Duration(seconds: value.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.download_for_offline_outlined),
                  onPressed: () => controller.downloadSurah(surah),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => controller.seek(
                    audioState.position - const Duration(seconds: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.togglePlay,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Icon(
                    audioState.playing ? Icons.pause : Icons.play_arrow,
                    size: 28,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => controller.seek(
                    audioState.position + const Duration(seconds: 10),
                  ),
                ),
                PopupMenuButton<QuranRepeatMode>(
                  initialValue: audioState.repeatMode,
                  onSelected: controller.setRepeatMode,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: QuranRepeatMode.none,
                      child: Text('بدون تكرار'),
                    ),
                    PopupMenuItem(
                      value: QuranRepeatMode.one,
                      child: Text('تكرار آية'),
                    ),
                    PopupMenuItem(
                      value: QuranRepeatMode.all,
                      child: Text('تكرار السورة'),
                    ),
                  ],
                  child: Icon(
                    switch (audioState.repeatMode) {
                      QuranRepeatMode.one => Icons.repeat_one,
                      QuranRepeatMode.all => Icons.repeat,
                      _ => Icons.repeat_outlined,
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
