import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../config.dart';
import '../models/quran_ayah.dart';
import '../models/surah.dart';
import '../local/json_loader.dart';

class QuranRepository {
  QuranRepository(this._bookmarksBox, this._recentsBox);

  final Box _bookmarksBox;
  final Box _recentsBox;

  List<Surah>? _surahCache;
  Map<int, List<QuranAyah>>? _samples;

  Future<List<Surah>> getSurahIndex() async {
    if (_surahCache != null) return _surahCache!;
    final data = await JsonLoader.loadList('assets/json/quran_index.json');
    _surahCache = data.map(Surah.fromIndexJson).toList(growable: false);
    return _surahCache!;
  }

  Future<Surah> getSurah(int number) async {
    final index = await getSurahIndex();
    final surah =
        index.firstWhere((s) => s.number == number, orElse: () => index.first);

    final ayat = await _loadSampleAyat(number);
    return surah.copyWithAyat(ayat);
  }

  Future<List<QuranAyah>> _loadSampleAyat(int number) async {
    if (_samples == null) {
      final raw = await rootBundle.loadString('assets/json/quran_samples.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _samples = data.map((key, value) {
        final list =
            (value as List<dynamic>).map((e) => QuranAyah.fromJson(e)).toList();
        return MapEntry(int.parse(key), list);
      });
    }
    return _samples![number] ??
        [
          QuranAyah(
            number: 1,
            text:
                'النص الكامل للسورة سيُضاف عند استيراد قاعدة البيانات الرسمية للقرآن الكريم.',
          ),
        ];
  }

  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    final current =
        (_bookmarksBox.get('items', defaultValue: <String>[]) as List).cast<String>();
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    await _bookmarksBox.put('items', current);
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    final current =
        (_bookmarksBox.get('items', defaultValue: <String>[]) as List).cast<String>();
    return current.contains(key);
  }

  Future<List<Map<String, int>>> getBookmarks() async {
    final current =
        (_bookmarksBox.get('items', defaultValue: <String>[]) as List).cast<String>();
    return current.map((entry) {
      final parts = entry.split(':');
      return {
        'surah': int.parse(parts[0]),
        'ayah': int.parse(parts[1]),
      };
    }).toList();
  }

  Future<void> markRecent(int surahNumber) async {
    final current =
        (_recentsBox.get('recent', defaultValue: <int>[]) as List).cast<int>();
    current.remove(surahNumber);
    current.insert(0, surahNumber);
    while (current.length > 10) {
      current.removeLast();
    }
    await _recentsBox.put('recent', current);
  }

  List<int> getRecents() {
    return (_recentsBox.get('recent', defaultValue: <int>[]) as List)
        .cast<int>();
  }

  QuranAyah? lastReadAyah(int surahNumber) {
    final map = (_recentsBox.get('lastAyah', defaultValue: <String, int>{})
        as Map?)?.cast<String, int>();
    final ayah = map?['$surahNumber'];
    if (ayah == null) return null;
    return QuranAyah(number: ayah, text: '');
  }

  Future<void> setLastReadAyah(int surahNumber, int ayahNumber) async {
    final map = (_recentsBox.get('lastAyah', defaultValue: <String, int>{})
        as Map?)?.cast<String, int>() ??
        <String, int>{};
    map['$surahNumber'] = ayahNumber;
    await _recentsBox.put('lastAyah', map);
  }
}
