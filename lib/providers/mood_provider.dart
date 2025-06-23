import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/storage_service.dart';
import '../utils/safe_provider_base.dart';

class MoodProvider extends SafeChangeNotifier {
  List<MoodEntry> _moods = [];
  bool _isLoading = false;

  List<MoodEntry> get moods => _moods;
  bool get isLoading => _isLoading;
  MoodProvider() {
    // Don't load moods immediately in constructor to avoid crashes
    Future.microtask(() => _loadMoods());
  }

  Future<void> _loadMoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _moods = StorageService.getAllMoods();
      _moods.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading moods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMood(MoodEntry mood) async {
    try {
      await StorageService.saveMood(mood);
      _moods.insert(0, mood);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding mood: $e');
      rethrow;
    }
  }

  Future<void> updateMood(MoodEntry mood) async {
    try {
      await StorageService.saveMood(mood);
      final index = _moods.indexWhere((m) => m.id == mood.id);
      if (index != -1) {
        _moods[index] = mood;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating mood: $e');
      rethrow;
    }
  }

  Future<void> deleteMood(String moodId) async {
    try {
      await StorageService.deleteMood(moodId);
      _moods.removeWhere((mood) => mood.id == moodId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting mood: $e');
      rethrow;
    }
  }

  MoodEntry? getMoodForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    try {
      return _moods.firstWhere((mood) {
        final moodDate = DateTime(
          mood.date.year,
          mood.date.month,
          mood.date.day,
        );
        return moodDate.isAtSameMomentAs(dateKey);
      });
    } catch (e) {
      return null;
    }
  }

  List<MoodEntry> getMoodsForWeek(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return _moods.where((mood) {
      return mood.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          mood.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<MoodEntry> getMoodsForMonth(DateTime date) {
    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 0);

    return _moods.where((mood) {
      return mood.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          mood.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();
  }

  Map<MoodType, int> getMoodFrequency({Duration? period}) {
    List<MoodEntry> moodsToAnalyze = _moods;

    if (period != null) {
      final cutoffDate = DateTime.now().subtract(period);
      moodsToAnalyze =
          _moods.where((mood) => mood.date.isAfter(cutoffDate)).toList();
    }

    final frequency = <MoodType, int>{};
    for (final mood in moodsToAnalyze) {
      frequency[mood.mood] = (frequency[mood.mood] ?? 0) + 1;
    }

    return frequency;
  }

  double getAverageMoodIntensity({Duration? period}) {
    List<MoodEntry> moodsToAnalyze = _moods;

    if (period != null) {
      final cutoffDate = DateTime.now().subtract(period);
      moodsToAnalyze =
          _moods.where((mood) => mood.date.isAfter(cutoffDate)).toList();
    }

    if (moodsToAnalyze.isEmpty) return 0.0;

    final totalIntensity = moodsToAnalyze.fold<int>(
      0,
      (sum, mood) => sum + mood.intensity,
    );

    return totalIntensity / moodsToAnalyze.length;
  }

  MoodType? getDominantMood({Duration? period}) {
    final frequency = getMoodFrequency(period: period);
    if (frequency.isEmpty) return null;

    return frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
