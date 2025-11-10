import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class JsonLoader {
  static final Map<String, List<dynamic>> _cache = {};

  static Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!.cast<Map<String, dynamic>>();
    }
    final raw = await rootBundle.loadString(assetPath);
    final parsed =
        await compute<String, List<dynamic>>(_parseJsonList, raw.trim());
    _cache[assetPath] = parsed;
    return parsed.cast<Map<String, dynamic>>();
  }

  static List<dynamic> _parseJsonList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw FormatException('Expected JSON list at asset');
  }
}
