import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../config.dart';
import '../../core/utils.dart';
import '../../data/models/surah.dart';
import '../../data/repositories/quran_repo.dart';
import '../../providers/app_providers.dart';
import 'download_manager.dart';

enum QuranRepeatMode { none, one, all }

class QuranAudioState {
  final bool loading;
  final bool playing;
  final Duration position;
  final Duration duration;
  final QuranRepeatMode repeatMode;
  final int currentAyah;

  const QuranAudioState({
    required this.loading,
    required this.playing,
    required this.position,
    required this.duration,
    required this.repeatMode,
    required this.currentAyah,
  });

  QuranAudioState copyWith({
    bool? loading,
    bool? playing,
    Duration? position,
    Duration? duration,
    QuranRepeatMode? repeatMode,
    int? currentAyah,
  }) {
    return QuranAudioState(
      loading: loading ?? this.loading,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      currentAyah: currentAyah ?? this.currentAyah,
    );
  }

  static QuranAudioState initial() => const QuranAudioState(
        loading: false,
        playing: false,
        position: Duration.zero,
        duration: Duration.zero,
        repeatMode: QuranRepeatMode.none,
        currentAyah: 1,
      );
}

class QuranAudioController extends StateNotifier<QuranAudioState> {
  QuranAudioController(
    this._reader,
    this._downloadManager,
  ) : super(QuranAudioState.initial()) {
    _init();
  }

  final Ref _reader;
  final QuranDownloadManager _downloadManager;
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _positionSub = _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _stateSub = _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        playing: playerState.playing,
        loading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  Future<void> loadSurah(Surah surah, {bool autoplay = false}) async {
    state = state.copyWith(loading: true);
    final surahCode = AppUtils.padSurahNumber(surah.number);
    final cachedFile = await _downloadManager.getCachedFile(surah.number);
    final url =
        AppConfig.kRecitationBase.replaceAll('{surah}', surahCode);

    final source = cachedFile != null
        ? AudioSource.uri(cachedFile.uri)
        : AudioSource.uri(Uri.parse(url));

    await _player.setAudioSource(source, preload: false);
    await _reader.read(quranRepositoryProvider).markRecent(surah.number);
    if (autoplay) {
      await play();
    }
    state = state.copyWith(loading: false, currentAyah: 1);
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> togglePlay() async {
    if (state.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> setRepeatMode(QuranRepeatMode mode) async {
    state = state.copyWith(repeatMode: mode);
    switch (mode) {
      case QuranRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
      case QuranRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
      case QuranRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
    }
  }

  Future<void> downloadSurah(Surah surah) async {
    state = state.copyWith(loading: true);
    await _downloadManager.cacheSurah(surah.number);
    state = state.copyWith(loading: false);
  }

  Future<void> deleteCache(Surah surah) async {
    await _downloadManager.deleteSurah(surah.number);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final quranAudioControllerProvider =
    StateNotifierProvider.autoDispose<QuranAudioController, QuranAudioState>(
  (ref) {
    final manager = ref.watch(quranDownloadManagerProvider);
    return QuranAudioController(ref, manager);
  },
);
