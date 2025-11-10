import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/quran_repo.dart';
import '../../providers/app_providers.dart';

class QuranBookmarksController
    extends StateNotifier<AsyncValue<List<Map<String, int>>>> {
  QuranBookmarksController(this._repository)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final QuranRepository _repository;

  Future<void> _load() async {
    try {
      final bookmarks = await _repository.getBookmarks();
      state = AsyncValue.data(bookmarks);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> toggle(int surah, int ayah) async {
    await _repository.toggleBookmark(surah, ayah);
    await _load();
  }
}

final quranBookmarksProvider = StateNotifierProvider<QuranBookmarksController,
    AsyncValue<List<Map<String, int>>>>(
  (ref) {
    final repo = ref.watch(quranRepositoryProvider);
    return QuranBookmarksController(repo);
  },
);
