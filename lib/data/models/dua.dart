class Dua {
  final String id;
  final String title;
  final String text;

  const Dua({
    required this.id,
    required this.title,
    required this.text,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
    };
  }
}
