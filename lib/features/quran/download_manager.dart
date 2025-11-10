import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config.dart';
import '../../core/utils.dart';

class QuranDownloadManager {
  QuranDownloadManager(this._dio);

  final Dio _dio;
  Directory? _cacheDir;

  Future<Directory> _ensureDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(p.join(dir.path, 'quran_cache'));
    if (!(await _cacheDir!.exists())) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  Future<File?> getCachedFile(int surahNumber) async {
    final dir = await _ensureDir();
    final path = p.join(dir.path, '${AppUtils.padSurahNumber(surahNumber)}.mp3');
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }

  Future<File> cacheSurah(int surahNumber) async {
    final dir = await _ensureDir();
    final path = p.join(dir.path, '${AppUtils.padSurahNumber(surahNumber)}.mp3');
    final url =
        AppConfig.kRecitationBase.replaceAll('{surah}', AppUtils.padSurahNumber(surahNumber));
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream),
    );
    final file = File(path);
    final raf = file.openSync(mode: FileMode.write);
    await response.data?.stream.forEach((chunk) {
      raf.writeFromSync(chunk);
    });
    await raf.close();
    await _enforceLimit();
    return file;
  }

  Future<void> deleteSurah(int surahNumber) async {
    final file = await getCachedFile(surahNumber);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearAll() async {
    final dir = await _ensureDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _cacheDir = null;
  }

  Future<void> _enforceLimit() async {
    final dir = await _ensureDir();
    final entries = dir
        .listSync()
        .whereType<File>()
        .map((file) => MapEntry(file, file.statSync()))
        .toList();
    entries.sort((a, b) => a.value.changed.compareTo(b.value.changed));

    var totalSize = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.value.size,
    );

    while (totalSize > AppConfig.audioCacheLimitBytes && entries.isNotEmpty) {
      final entry = entries.removeAt(0);
      totalSize -= entry.value.size;
      await entry.key.delete();
    }
  }
}

final quranDownloadManagerProvider = Provider<QuranDownloadManager>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 7),
    receiveTimeout: const Duration(seconds: 20),
  ));
  return QuranDownloadManager(dio);
});
