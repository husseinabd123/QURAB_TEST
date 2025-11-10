import 'package:hive/hive.dart';

part 'dhikr.g.dart';

enum DhikrTime {
  morning,
  evening,
  afterPrayer,
  anytime,
}

@HiveType(typeId: 2)
class Dhikr {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int repeatCount;

  @HiveField(3)
  final String time; // 'morning', 'evening', 'after_prayer', 'anytime'

  @HiveField(4)
  final String? reference;

  @HiveField(5)
  int currentCount;

  Dhikr({
    required this.id,
    required this.text,
    required this.repeatCount,
    required this.time,
    this.reference,
    this.currentCount = 0,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'] as String,
      text: json['text'] as String,
      repeatCount: json['repeat'] as int,
      time: json['time'] as String,
      reference: json['reference'] as String?,
      currentCount: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'repeat': repeatCount,
      'time': time,
      'reference': reference,
    };
  }

  DhikrTime get dhikrTime {
    switch (time) {
      case 'morning':
        return DhikrTime.morning;
      case 'evening':
        return DhikrTime.evening;
      case 'after_prayer':
        return DhikrTime.afterPrayer;
      default:
        return DhikrTime.anytime;
    }
  }

  bool get isCompleted => currentCount >= repeatCount;

  double get progress => repeatCount > 0 ? currentCount / repeatCount : 0.0;

  Dhikr copyWith({
    String? id,
    String? text,
    int? repeatCount,
    String? time,
    String? reference,
    int? currentCount,
  }) {
    return Dhikr(
      id: id ?? this.id,
      text: text ?? this.text,
      repeatCount: repeatCount ?? this.repeatCount,
      time: time ?? this.time,
      reference: reference ?? this.reference,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
