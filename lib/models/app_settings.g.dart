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
      pinCode: fields[5] as String?,
      lastEntryDate: fields[18] as DateTime?,
    )
      .._isDarkMode = fields[0] as bool?
      .._isBiometricEnabled = fields[1] as bool?
      .._isNotificationEnabled = fields[2] as bool?
      .._notificationHour = fields[3] as int?
      .._notificationMinute = fields[4] as int?
      .._isFirstTime = fields[6] as bool?
      .._isPremium = fields[7] as bool?
      .._isMoodTrackingEnabled = fields[8] as bool?
      .._isVoiceInputEnabled = fields[9] as bool?
      .._isAIInsightsEnabled = fields[10] as bool?
      .._isCloudSyncEnabled = fields[11] as bool?
      .._selectedTheme = fields[12] as String?
      .._selectedFont = fields[13] as String?
      .._fontSize = fields[14] as double?
      .._preferredPromptCategory = fields[15] as PromptCategory?
      .._unlockedThemes = (fields[16] as List?)?.cast<String>()
      .._streakCount = fields[17] as int?
      .._earnedBadges = (fields[19] as List?)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj._isDarkMode)
      ..writeByte(1)
      ..write(obj._isBiometricEnabled)
      ..writeByte(2)
      ..write(obj._isNotificationEnabled)
      ..writeByte(3)
      ..write(obj._notificationHour)
      ..writeByte(4)
      ..write(obj._notificationMinute)
      ..writeByte(5)
      ..write(obj.pinCode)
      ..writeByte(6)
      ..write(obj._isFirstTime)
      ..writeByte(7)
      ..write(obj._isPremium)
      ..writeByte(8)
      ..write(obj._isMoodTrackingEnabled)
      ..writeByte(9)
      ..write(obj._isVoiceInputEnabled)
      ..writeByte(10)
      ..write(obj._isAIInsightsEnabled)
      ..writeByte(11)
      ..write(obj._isCloudSyncEnabled)
      ..writeByte(12)
      ..write(obj._selectedTheme)
      ..writeByte(13)
      ..write(obj._selectedFont)
      ..writeByte(14)
      ..write(obj._fontSize)
      ..writeByte(15)
      ..write(obj._preferredPromptCategory)
      ..writeByte(16)
      ..write(obj._unlockedThemes)
      ..writeByte(17)
      ..write(obj._streakCount)
      ..writeByte(18)
      ..write(obj.lastEntryDate)
      ..writeByte(19)
      ..write(obj._earnedBadges);
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
