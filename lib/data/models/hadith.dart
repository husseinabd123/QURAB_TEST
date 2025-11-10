import 'package:hive/hive.dart';

part 'hadith.g.dart';

@HiveType(typeId: 0)
class Hadith {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String source;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final String? reference;

  @HiveField(5)
  bool isFavorite;

  Hadith({
    required this.id,
    required this.source,
    required this.text,
    required this.tags,
    this.reference,
    this.isFavorite = false,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as String,
      source: json['source'] as String,
      text: json['text'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      reference: json['ref'] as String?,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'text': text,
      'tags': tags,
      'ref': reference,
    };
  }

  Hadith copyWith({
    String? id,
    String? source,
    String? text,
    List<String>? tags,
    String? reference,
    bool? isFavorite,
  }) {
    return Hadith(
      id: id ?? this.id,
      source: source ?? this.source,
      text: text ?? this.text,
      tags: tags ?? this.tags,
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
