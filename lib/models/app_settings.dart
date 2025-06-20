import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool isBiometricEnabled;

  @HiveField(2)
  bool isNotificationEnabled;

  @HiveField(3)
  int notificationHour;

  @HiveField(4)
  int notificationMinute;

  @HiveField(5)
  String? pinCode;

  @HiveField(6)
  bool isFirstTime;

  AppSettings({
    this.isDarkMode = false,
    this.isBiometricEnabled = false,
    this.isNotificationEnabled = true,
    this.notificationHour = 20,
    this.notificationMinute = 0,
    this.pinCode,
    this.isFirstTime = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isNotificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? pinCode,
    bool? isFirstTime,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      pinCode: pinCode ?? this.pinCode,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}
