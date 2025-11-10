import 'package:hive/hive.dart';

part 'quran_ayah.g.dart';

@HiveType(typeId: 4)
class QuranAyah {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int surahNumber;

  @HiveField(3)
  final int ayahNumber;

  @HiveField(4)
  final int juz;

  @HiveField(5)
  final int page;

  @HiveField(6)
  bool isBookmarked;

  QuranAyah({
    required this.number,
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
    this.juz = 1,
    this.page = 1,
    this.isBookmarked = false,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: json['number'] as int,
      text: json['text'] as String,
      surahNumber: json['surah'] as int,
      ayahNumber: json['ayah'] as int,
      juz: json['juz'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      isBookmarked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
      'surah': surahNumber,
      'ayah': ayahNumber,
      'juz': juz,
      'page': page,
    };
  }

  QuranAyah copyWith({
    int? number,
    String? text,
    int? surahNumber,
    int? ayahNumber,
    int? juz,
    int? page,
    bool? isBookmarked,
  }) {
    return QuranAyah(
      number: number ?? this.number,
      text: text ?? this.text,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
