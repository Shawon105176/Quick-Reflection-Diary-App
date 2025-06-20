import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 2)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  MoodType mood;

  @HiveField(3)
  int intensity; // 1-5 scale

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.intensity,
    this.notes,
    required this.createdAt,
  });

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    MoodType? mood,
    int? intensity,
    String? notes,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 3)
enum MoodType {
  @HiveField(0)
  happy,
  @HiveField(1)
  sad,
  @HiveField(2)
  anxious,
  @HiveField(3)
  excited,
  @HiveField(4)
  calm,
  @HiveField(5)
  angry,
  @HiveField(6)
  peaceful,
  @HiveField(7)
  stressed,
  @HiveField(8)
  content,
  @HiveField(9)
  frustrated,
}

extension MoodTypeExtension on MoodType {
  String get displayName {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.sad:
        return 'Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.excited:
        return 'Excited';
      case MoodType.calm:
        return 'Calm';
      case MoodType.angry:
        return 'Angry';
      case MoodType.peaceful:
        return 'Peaceful';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.content:
        return 'Content';
      case MoodType.frustrated:
        return 'Frustrated';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.excited:
        return '🤩';
      case MoodType.calm:
        return '😌';
      case MoodType.angry:
        return '😠';
      case MoodType.peaceful:
        return '☮️';
      case MoodType.stressed:
        return '😖';
      case MoodType.content:
        return '😇';
      case MoodType.frustrated:
        return '😤';
    }
  }
}
