// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      isBiometricEnabled: fields[1] as bool,
      isNotificationEnabled: fields[2] as bool,
      notificationHour: fields[3] as int,
      notificationMinute: fields[4] as int,
      pinCode: fields[5] as String?,
      isFirstTime: fields[6] as bool,
      isPremium: fields[7] as bool,
      isMoodTrackingEnabled: fields[8] as bool,
      isVoiceInputEnabled: fields[9] as bool,
      isAIInsightsEnabled: fields[10] as bool,
      isCloudSyncEnabled: fields[11] as bool,
      selectedTheme: fields[12] as String,
      selectedFont: fields[13] as String,
      fontSize: fields[14] as double,
      preferredPromptCategory: fields[15] as PromptCategory,
      unlockedThemes: (fields[16] as List).cast<String>(),
      streakCount: fields[17] as int,
      lastEntryDate: fields[18] as DateTime?,
      earnedBadges: (fields[19] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.isBiometricEnabled)
      ..writeByte(2)
      ..write(obj.isNotificationEnabled)
      ..writeByte(3)
      ..write(obj.notificationHour)
      ..writeByte(4)
      ..write(obj.notificationMinute)
      ..writeByte(5)
      ..write(obj.pinCode)
      ..writeByte(6)
      ..write(obj.isFirstTime)
      ..writeByte(7)
      ..write(obj.isPremium)
      ..writeByte(8)
      ..write(obj.isMoodTrackingEnabled)
      ..writeByte(9)
      ..write(obj.isVoiceInputEnabled)
      ..writeByte(10)
      ..write(obj.isAIInsightsEnabled)
      ..writeByte(11)
      ..write(obj.isCloudSyncEnabled)
      ..writeByte(12)
      ..write(obj.selectedTheme)
      ..writeByte(13)
      ..write(obj.selectedFont)
      ..writeByte(14)
      ..write(obj.fontSize)
      ..writeByte(15)
      ..write(obj.preferredPromptCategory)
      ..writeByte(16)
      ..write(obj.unlockedThemes)
      ..writeByte(17)
      ..write(obj.streakCount)
      ..writeByte(18)
      ..write(obj.lastEntryDate)
      ..writeByte(19)
      ..write(obj.earnedBadges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
