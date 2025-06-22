import 'package:hive/hive.dart';
import 'prompt_category.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool? _isDarkMode;

  @HiveField(1)
  bool? _isBiometricEnabled;

  @HiveField(2)
  bool? _isNotificationEnabled;

  @HiveField(3)
  int? _notificationHour;

  @HiveField(4)
  int? _notificationMinute;

  @HiveField(5)
  String? pinCode;

  @HiveField(6)
  bool? _isFirstTime;

  // Premium Features
  @HiveField(7)
  bool? _isPremium;

  @HiveField(8)
  bool? _isMoodTrackingEnabled;

  @HiveField(9)
  bool? _isVoiceInputEnabled;

  @HiveField(10)
  bool? _isAIInsightsEnabled;

  @HiveField(11)
  bool? _isCloudSyncEnabled;

  @HiveField(12)
  String? _selectedTheme;

  @HiveField(13)
  String? _selectedFont;

  @HiveField(14)
  double? _fontSize;

  @HiveField(15)
  PromptCategory? _preferredPromptCategory;

  @HiveField(16)
  List<String>? _unlockedThemes;

  @HiveField(17)
  int? _streakCount;

  @HiveField(18)
  DateTime? lastEntryDate;
  @HiveField(19)
  List<String>? _earnedBadges;

  @HiveField(20)
  String? _userName;

  // Getters with default values
  bool get isDarkMode => _isDarkMode ?? false;
  bool get isBiometricEnabled => _isBiometricEnabled ?? false;
  bool get isNotificationEnabled => _isNotificationEnabled ?? true;
  int get notificationHour => _notificationHour ?? 20;
  int get notificationMinute => _notificationMinute ?? 0;
  bool get isFirstTime => _isFirstTime ?? true;
  bool get isPremium => _isPremium ?? false;
  bool get isMoodTrackingEnabled => _isMoodTrackingEnabled ?? false;
  bool get isVoiceInputEnabled => _isVoiceInputEnabled ?? false;
  bool get isAIInsightsEnabled => _isAIInsightsEnabled ?? false;
  bool get isCloudSyncEnabled => _isCloudSyncEnabled ?? false;
  String get selectedTheme => _selectedTheme ?? 'default';
  String get selectedFont => _selectedFont ?? 'system';
  double get fontSize => _fontSize ?? 16.0;
  PromptCategory get preferredPromptCategory =>
      _preferredPromptCategory ?? PromptCategory.random;
  List<String> get unlockedThemes => _unlockedThemes ?? ['default'];
  int get streakCount => _streakCount ?? 0;
  List<String> get earnedBadges => _earnedBadges ?? [];
  String get userName => _userName ?? '';

  AppSettings({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isNotificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    this.pinCode,
    bool? isFirstTime,
    // Premium defaults
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
    this.lastEntryDate,
    List<String>? earnedBadges,
    String? userName,
  }) : _isDarkMode = isDarkMode ?? false,
       _isBiometricEnabled = isBiometricEnabled ?? false,
       _isNotificationEnabled = isNotificationEnabled ?? true,
       _notificationHour = notificationHour ?? 20,
       _notificationMinute = notificationMinute ?? 0,
       _isFirstTime = isFirstTime ?? true,
       _isPremium = isPremium ?? false,
       _isMoodTrackingEnabled = isMoodTrackingEnabled ?? false,
       _isVoiceInputEnabled = isVoiceInputEnabled ?? false,
       _isAIInsightsEnabled = isAIInsightsEnabled ?? false,
       _isCloudSyncEnabled = isCloudSyncEnabled ?? false,
       _selectedTheme = selectedTheme ?? 'default',
       _selectedFont = selectedFont ?? 'system',
       _fontSize = fontSize ?? 16.0,
       _preferredPromptCategory =
           preferredPromptCategory ?? PromptCategory.random,
       _unlockedThemes = unlockedThemes ?? ['default'],
       _streakCount = streakCount ?? 0,
       _earnedBadges = earnedBadges ?? [],
       _userName = userName ?? '';

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
    String? userName,
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
      userName: userName ?? this.userName,
    );
  }

  bool get hasStreak => streakCount > 0;

  bool get canEarnStreakBadge {
    return streakCount >= 5 && !earnedBadges.contains('5_day_streak');
  }
}
