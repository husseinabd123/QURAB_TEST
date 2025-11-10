import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class JsonLoader {
  JsonLoader._();

  /// Load and parse JSON from assets using isolate for heavy files
  static Future<dynamic> loadJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      
      // Use compute for large files to avoid blocking UI thread
      if (jsonString.length > 100000) {
        return await compute(_parseJson, jsonString);
      } else {
        return json.decode(jsonString);
      }
    } catch (e) {
      debugPrint('Error loading JSON from $path: $e');
      rethrow;
    }
  }

  /// Parse JSON in isolate
  static dynamic _parseJson(String jsonString) {
    return json.decode(jsonString);
  }

  /// Load hadith data
  static Future<List<Map<String, dynamic>>> loadHadithData() async {
    try {
      final data = await loadJson('assets/json/hadith.json');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('Error loading hadith data: $e');
      return [];
    }
  }

  /// Load duas data
  static Future<List<Map<String, dynamic>>> loadDuasData() async {
    try {
      final data = await loadJson('assets/json/duas.json');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('Error loading duas data: $e');
      return [];
    }
  }

  /// Load adhkar data
  static Future<List<Map<String, dynamic>>> loadAdhkarData() async {
    try {
      final data = await loadJson('assets/json/adhkar.json');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('Error loading adhkar data: $e');
      return [];
    }
  }

  /// Load Quran index data
  static Future<List<Map<String, dynamic>>> loadQuranIndex() async {
    try {
      final data = await loadJson('assets/json/quran_index.json');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('Error loading Quran index: $e');
      return [];
    }
  }
}
