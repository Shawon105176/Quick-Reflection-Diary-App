import 'package:hive_flutter/hive_flutter.dart';
import '../models/reflection_entry.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _reflectionsBoxName = 'reflections';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  static Box<ReflectionEntry>? _reflectionsBox;
  static Box<AppSettings>? _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ReflectionEntryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Open boxes
    _reflectionsBox = await Hive.openBox<ReflectionEntry>(_reflectionsBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
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

  // Clear all data (for logout or reset)
  static Future<void> clearAllData() async {
    await _reflectionsBox?.clear();
    await _settingsBox?.clear();
  }

  // Close boxes (call on app dispose)
  static Future<void> dispose() async {
    await _reflectionsBox?.close();
    await _settingsBox?.close();
  }
}
