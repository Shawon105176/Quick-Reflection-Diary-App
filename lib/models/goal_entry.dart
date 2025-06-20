import 'package:hive/hive.dart';

part 'goal_entry.g.dart';

@HiveType(typeId: 4)
class GoalEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  GoalCategory category;

  @HiveField(7)
  List<String> milestones;

  @HiveField(8)
  List<String> completedMilestones;

  GoalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
    required this.category,
    this.milestones = const [],
    this.completedMilestones = const [],
  });

  GoalEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isCompleted,
    GoalCategory? category,
    List<String>? milestones,
    List<String>? completedMilestones,
  }) {
    return GoalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      milestones: milestones ?? this.milestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
    );
  }

  double get progress {
    if (milestones.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedMilestones.length / milestones.length;
  }
}

@HiveType(typeId: 5)
enum GoalCategory {
  @HiveField(0)
  personal,
  @HiveField(1)
  health,
  @HiveField(2)
  career,
  @HiveField(3)
  relationships,
  @HiveField(4)
  finance,
  @HiveField(5)
  education,
  @HiveField(6)
  creativity,
  @HiveField(7)
  spirituality,
}

extension GoalCategoryExtension on GoalCategory {
  String get displayName {
    switch (this) {
      case GoalCategory.personal:
        return 'Personal';
      case GoalCategory.health:
        return 'Health & Fitness';
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.creativity:
        return 'Creativity';
      case GoalCategory.spirituality:
        return 'Spirituality';
    }
  }

  String get icon {
    switch (this) {
      case GoalCategory.personal:
        return '🎯';
      case GoalCategory.health:
        return '💪';
      case GoalCategory.career:
        return '💼';
      case GoalCategory.relationships:
        return '💝';
      case GoalCategory.finance:
        return '💰';
      case GoalCategory.education:
        return '📚';
      case GoalCategory.creativity:
        return '🎨';
      case GoalCategory.spirituality:
        return '🧘';
    }
  }
}
