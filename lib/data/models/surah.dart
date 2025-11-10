import 'package:hive/hive.dart';

part 'surah.g.dart';

@HiveType(typeId: 3)
class Surah {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String transliteration;

  @HiveField(3)
  final int ayahCount;

  @HiveField(4)
  final String revelationType; // 'Meccan' or 'Medinan'

  @HiveField(5)
  bool isFavorite;

  Surah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.ayahCount,
    required this.revelationType,
    this.isFavorite = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      transliteration: json['transliteration'] as String? ?? '',
      ayahCount: json['ayahs'] as int,
      revelationType: json['type'] as String? ?? 'Meccan',
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'transliteration': transliteration,
      'ayahs': ayahCount,
      'type': revelationType,
    };
  }

  Surah copyWith({
    int? number,
    String? name,
    String? transliteration,
    int? ayahCount,
    String? revelationType,
    bool? isFavorite,
  }) {
    return Surah(
      number: number ?? this.number,
      name: name ?? this.name,
      transliteration: transliteration ?? this.transliteration,
      ayahCount: ayahCount ?? this.ayahCount,
      revelationType: revelationType ?? this.revelationType,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
