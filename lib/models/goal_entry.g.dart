// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalEntryAdapter extends TypeAdapter<GoalEntry> {
  @override
  final int typeId = 4;

  @override
  GoalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      deadline: fields[4] as DateTime?,
      isCompleted: fields[5] as bool,
      category: fields[6] as GoalCategory,
      milestones: (fields[7] as List).cast<String>(),
      completedMilestones: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.milestones)
      ..writeByte(8)
      ..write(obj.completedMilestones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalCategoryAdapter extends TypeAdapter<GoalCategory> {
  @override
  final int typeId = 5;

  @override
  GoalCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalCategory.personal;
      case 1:
        return GoalCategory.health;
      case 2:
        return GoalCategory.career;
      case 3:
        return GoalCategory.relationships;
      case 4:
        return GoalCategory.finance;
      case 5:
        return GoalCategory.education;
      case 6:
        return GoalCategory.creativity;
      case 7:
        return GoalCategory.spirituality;
      default:
        return GoalCategory.personal;
    }
  }

  @override
  void write(BinaryWriter writer, GoalCategory obj) {
    switch (obj) {
      case GoalCategory.personal:
        writer.writeByte(0);
        break;
      case GoalCategory.health:
        writer.writeByte(1);
        break;
      case GoalCategory.career:
        writer.writeByte(2);
        break;
      case GoalCategory.relationships:
        writer.writeByte(3);
        break;
      case GoalCategory.finance:
        writer.writeByte(4);
        break;
      case GoalCategory.education:
        writer.writeByte(5);
        break;
      case GoalCategory.creativity:
        writer.writeByte(6);
        break;
      case GoalCategory.spirituality:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
