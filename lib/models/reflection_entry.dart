import 'package:hive/hive.dart';

part 'reflection_entry.g.dart';

@HiveType(typeId: 0)
class ReflectionEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String prompt;

  @HiveField(3)
  String reflection;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  ReflectionEntry({
    required this.id,
    required this.date,
    required this.prompt,
    required this.reflection,
    required this.createdAt,
    this.updatedAt,
  });

  ReflectionEntry copyWith({
    String? id,
    DateTime? date,
    String? prompt,
    String? reflection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReflectionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      prompt: prompt ?? this.prompt,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReflectionEntry(id: $id, date: $date, prompt: $prompt, reflection: $reflection)';
  }
}
