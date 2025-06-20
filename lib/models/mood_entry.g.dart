// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 2;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as MoodType,
      intensity: fields[3] as int,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.intensity)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodTypeAdapter extends TypeAdapter<MoodType> {
  @override
  final int typeId = 3;

  @override
  MoodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodType.happy;
      case 1:
        return MoodType.sad;
      case 2:
        return MoodType.anxious;
      case 3:
        return MoodType.excited;
      case 4:
        return MoodType.calm;
      case 5:
        return MoodType.angry;
      case 6:
        return MoodType.peaceful;
      case 7:
        return MoodType.stressed;
      case 8:
        return MoodType.content;
      case 9:
        return MoodType.frustrated;
      default:
        return MoodType.happy;
    }
  }

  @override
  void write(BinaryWriter writer, MoodType obj) {
    switch (obj) {
      case MoodType.happy:
        writer.writeByte(0);
        break;
      case MoodType.sad:
        writer.writeByte(1);
        break;
      case MoodType.anxious:
        writer.writeByte(2);
        break;
      case MoodType.excited:
        writer.writeByte(3);
        break;
      case MoodType.calm:
        writer.writeByte(4);
        break;
      case MoodType.angry:
        writer.writeByte(5);
        break;
      case MoodType.peaceful:
        writer.writeByte(6);
        break;
      case MoodType.stressed:
        writer.writeByte(7);
        break;
      case MoodType.content:
        writer.writeByte(8);
        break;
      case MoodType.frustrated:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
