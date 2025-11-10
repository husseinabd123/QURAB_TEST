import 'package:hive/hive.dart';

part 'dua.g.dart';

@HiveType(typeId: 1)
class Dua {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final String? translation;

  @HiveField(4)
  final String? reference;

  @HiveField(5)
  bool isFavorite;

  Dua({
    required this.id,
    required this.title,
    required this.text,
    this.translation,
    this.reference,
    this.isFavorite = false,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      translation: json['translation'] as String?,
      reference: json['reference'] as String?,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'translation': translation,
      'reference': reference,
    };
  }

  Dua copyWith({
    String? id,
    String? title,
    String? text,
    String? translation,
    String? reference,
    bool? isFavorite,
  }) {
    return Dua(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
