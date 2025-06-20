// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromptCategoryAdapter extends TypeAdapter<PromptCategory> {
  @override
  final int typeId = 6;

  @override
  PromptCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PromptCategory.mentalHealth;
      case 1:
        return PromptCategory.relationships;
      case 2:
        return PromptCategory.gratitude;
      case 3:
        return PromptCategory.selfDiscovery;
      case 4:
        return PromptCategory.creativity;
      case 5:
        return PromptCategory.goals;
      case 6:
        return PromptCategory.mindfulness;
      case 7:
        return PromptCategory.random;
      default:
        return PromptCategory.mentalHealth;
    }
  }

  @override
  void write(BinaryWriter writer, PromptCategory obj) {
    switch (obj) {
      case PromptCategory.mentalHealth:
        writer.writeByte(0);
        break;
      case PromptCategory.relationships:
        writer.writeByte(1);
        break;
      case PromptCategory.gratitude:
        writer.writeByte(2);
        break;
      case PromptCategory.selfDiscovery:
        writer.writeByte(3);
        break;
      case PromptCategory.creativity:
        writer.writeByte(4);
        break;
      case PromptCategory.goals:
        writer.writeByte(5);
        break;
      case PromptCategory.mindfulness:
        writer.writeByte(6);
        break;
      case PromptCategory.random:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
