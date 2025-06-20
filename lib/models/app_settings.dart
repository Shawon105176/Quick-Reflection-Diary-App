import 'package:hive/hive.dart';
import 'prompt_category.dart';

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

  // Premium Features
  @HiveField(7)
  bool isPremium;

  @HiveField(8)
  bool isMoodTrackingEnabled;

  @HiveField(9)
  bool isVoiceInputEnabled;

  @HiveField(10)
  bool isAIInsightsEnabled;

  @HiveField(11)
  bool isCloudSyncEnabled;

  @HiveField(12)
  String selectedTheme;

  @HiveField(13)
  String selectedFont;

  @HiveField(14)
  double fontSize;

  @HiveField(15)
  PromptCategory preferredPromptCategory;

  @HiveField(16)
  List<String> unlockedThemes;

  @HiveField(17)
  int streakCount;

  @HiveField(18)
  DateTime? lastEntryDate;

  @HiveField(19)
  List<String> earnedBadges;

  AppSettings({
    this.isDarkMode = false,
    this.isBiometricEnabled = false,
    this.isNotificationEnabled = true,
    this.notificationHour = 20,
    this.notificationMinute = 0,
    this.pinCode,
    this.isFirstTime = true,
    // Premium defaults
    this.isPremium = false,
    this.isMoodTrackingEnabled = false,
    this.isVoiceInputEnabled = false,
    this.isAIInsightsEnabled = false,
    this.isCloudSyncEnabled = false,
    this.selectedTheme = 'default',
    this.selectedFont = 'system',
    this.fontSize = 16.0,
    this.preferredPromptCategory = PromptCategory.random,
    this.unlockedThemes = const ['default'],
    this.streakCount = 0,
    this.lastEntryDate,
    this.earnedBadges = const [],
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isNotificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? pinCode,
    bool? isFirstTime,
    bool? isPremium,
    bool? isMoodTrackingEnabled,
    bool? isVoiceInputEnabled,
    bool? isAIInsightsEnabled,
    bool? isCloudSyncEnabled,
    String? selectedTheme,
    String? selectedFont,
    double? fontSize,
    PromptCategory? preferredPromptCategory,
    List<String>? unlockedThemes,
    int? streakCount,
    DateTime? lastEntryDate,
    List<String>? earnedBadges,
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
      isPremium: isPremium ?? this.isPremium,
      isMoodTrackingEnabled:
          isMoodTrackingEnabled ?? this.isMoodTrackingEnabled,
      isVoiceInputEnabled: isVoiceInputEnabled ?? this.isVoiceInputEnabled,
      isAIInsightsEnabled: isAIInsightsEnabled ?? this.isAIInsightsEnabled,
      isCloudSyncEnabled: isCloudSyncEnabled ?? this.isCloudSyncEnabled,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedFont: selectedFont ?? this.selectedFont,
      fontSize: fontSize ?? this.fontSize,
      preferredPromptCategory:
          preferredPromptCategory ?? this.preferredPromptCategory,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      streakCount: streakCount ?? this.streakCount,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }

  bool get hasStreak => streakCount > 0;

  bool get canEarnStreakBadge {
    return streakCount >= 5 && !earnedBadges.contains('5_day_streak');
  }
}
