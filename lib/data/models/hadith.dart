class Hadith {
  final String id;
  final String source;
  final String text;
  final List<String> tags;
  final String ref;

  const Hadith({
    required this.id,
    required this.source,
    required this.text,
    required this.tags,
    required this.ref,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as String,
      source: json['source'] as String,
      text: json['text'] as String,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      ref: json['ref'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'text': text,
      'tags': tags,
      'ref': ref,
    };
  }
}
