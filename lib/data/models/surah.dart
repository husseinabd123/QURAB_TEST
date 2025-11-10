import 'quran_ayah.dart';

class Surah {
  final int number;
  final String name;
  final int ayahCount;
  final List<QuranAyah> ayat;

  const Surah({
    required this.number,
    required this.name,
    required this.ayahCount,
    this.ayat = const [],
  });

  factory Surah.fromIndexJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      ayahCount: json['ayahs'] as int,
    );
  }

  Surah copyWithAyat(List<QuranAyah> ayat) {
    return Surah(
      number: number,
      name: name,
      ayahCount: ayahCount,
      ayat: ayat,
    );
  }
}
