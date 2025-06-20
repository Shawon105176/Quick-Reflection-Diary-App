// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionEntryAdapter extends TypeAdapter<ReflectionEntry> {
  @override
  final int typeId = 0;

  @override
  ReflectionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReflectionEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      prompt: fields[2] as String,
      reflection: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReflectionEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.prompt)
      ..writeByte(3)
      ..write(obj.reflection)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
