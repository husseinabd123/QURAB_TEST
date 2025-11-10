class Dhikr {
  final String id;
  final String text;
  final int repeat;
  final String time;

  const Dhikr({
    required this.id,
    required this.text,
    required this.repeat,
    required this.time,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'] as String,
      text: json['text'] as String,
      repeat: json['repeat'] as int? ?? 1,
      time: json['time'] as String? ?? 'any',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'repeat': repeat,
      'time': time,
    };
  }
}
