import 'package:hive_flutter/hive_flutter.dart';
import '../models/reflection_entry.dart';
import '../models/app_settings.dart';
import '../models/mood_entry.dart';
import '../models/goal_entry.dart';
import '../models/prompt_category.dart';

class StorageService {
  static const String _reflectionsBoxName = 'reflections';
  static const String _settingsBoxName = 'settings';
  static const String _moodsBoxName = 'moods';
  static const String _goalsBoxName = 'goals';
  static const String _settingsKey = 'app_settings';

  static Box<ReflectionEntry>? _reflectionsBox;
  static Box<AppSettings>? _settingsBox;
  static Box<MoodEntry>? _moodsBox;
  static Box<GoalEntry>? _goalsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ReflectionEntryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(MoodEntryAdapter());
    Hive.registerAdapter(MoodTypeAdapter());
    Hive.registerAdapter(GoalEntryAdapter());
    Hive.registerAdapter(GoalCategoryAdapter());
    Hive.registerAdapter(PromptCategoryAdapter());

    // Open boxes
    _reflectionsBox = await Hive.openBox<ReflectionEntry>(_reflectionsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    _moodsBox = await Hive.openBox<MoodEntry>(_moodsBoxName);
    _goalsBox = await Hive.openBox<GoalEntry>(_goalsBoxName);
  }

  // Reflection entries methods
  static Future<void> saveReflection(ReflectionEntry entry) async {
    await _reflectionsBox?.put(entry.id, entry);
  }

  static Future<void> deleteReflection(String id) async {
    await _reflectionsBox?.delete(id);
  }

  static ReflectionEntry? getReflectionById(String id) {
    return _reflectionsBox?.get(id);
  }

  static List<ReflectionEntry> getAllReflections() {
    return _reflectionsBox?.values.toList() ?? [];
  }

  static List<ReflectionEntry> getReflectionsByMonth(int year, int month) {
    final allReflections = getAllReflections();
    return allReflections.where((entry) {
      return entry.date.year == year && entry.date.month == month;
    }).toList();
  }

  static ReflectionEntry? getReflectionForDate(DateTime date) {
    final allReflections = getAllReflections();
    for (final entry in allReflections) {
      if (entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day) {
        return entry;
      }
    }
    return null;
  }

  static List<DateTime> getDatesWithReflections() {
    final allReflections = getAllReflections();
    return allReflections.map((entry) => entry.date).toList();
  }

  // Settings methods
  static Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox?.put(_settingsKey, settings);
  }

  static AppSettings getSettings() {
    return _settingsBox?.get(_settingsKey) ?? AppSettings();
  }

  // Mood entries methods
  static Future<void> saveMood(MoodEntry mood) async {
    await _moodsBox?.put(mood.id, mood);
  }

  static Future<void> deleteMood(String id) async {
    await _moodsBox?.delete(id);
  }

  static MoodEntry? getMoodById(String id) {
    return _moodsBox?.get(id);
  }

  static List<MoodEntry> getAllMoods() {
    return _moodsBox?.values.toList() ?? [];
  }

  static MoodEntry? getMoodForDate(DateTime date) {
    final allMoods = getAllMoods();
    for (final mood in allMoods) {
      if (mood.date.year == date.year &&
          mood.date.month == date.month &&
          mood.date.day == date.day) {
        return mood;
      }
    }
    return null;
  }

  // Goal entries methods
  static Future<void> saveGoal(GoalEntry goal) async {
    await _goalsBox?.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await _goalsBox?.delete(id);
  }

  static GoalEntry? getGoalById(String id) {
    return _goalsBox?.get(id);
  }

  static List<GoalEntry> getAllGoals() {
    return _goalsBox?.values.toList() ?? [];
  }

  static List<GoalEntry> getActiveGoals() {
    return getAllGoals().where((goal) => !goal.isCompleted).toList();
  }

  static List<GoalEntry> getCompletedGoals() {
    return getAllGoals().where((goal) => goal.isCompleted).toList();
  }

  // Clear all data (for logout or reset)
  static Future<void> clearAllData() async {
    await _reflectionsBox?.clear();
    await _settingsBox?.clear();
    await _moodsBox?.clear();
    await _goalsBox?.clear();
  }

  // Close boxes (call on app dispose)
  static Future<void> dispose() async {
    await _reflectionsBox?.close();
    await _settingsBox?.close();
    await _moodsBox?.close();
    await _goalsBox?.close();
  }
}
