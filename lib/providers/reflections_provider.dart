import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reflection_entry.dart';
import '../services/storage_service.dart';
import '../services/prompt_service.dart';
import 'package:uuid/uuid.dart';

class ReflectionsProvider extends ChangeNotifier {
  List<ReflectionEntry> _reflections = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<ReflectionEntry> get reflections => List.unmodifiable(_reflections);
  bool get isLoading => _isLoading;
  ReflectionsProvider() {
    // Don't load reflections immediately in constructor to avoid crashes
    Future.microtask(() => _loadReflections());
  }

  Future<void> _loadReflections() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reflections = StorageService.getAllReflections();
      _reflections.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by date descending
    } catch (e) {
      debugPrint('Error loading reflections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReflection({
    required DateTime date,
    required String reflection,
    String? customPrompt,
  }) async {
    final prompt = customPrompt ?? PromptService.getPromptForDate(date);
    final entry = ReflectionEntry(
      id: _uuid.v4(),
      date: date,
      prompt: prompt,
      reflection: reflection,
      createdAt: DateTime.now(),
    );

    await StorageService.saveReflection(entry);
    _reflections.add(entry);
    _reflections.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateReflection({
    required String id,
    required String reflection,
  }) async {
    final index = _reflections.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      final updatedEntry = _reflections[index].copyWith(
        reflection: reflection,
        updatedAt: DateTime.now(),
      );

      await StorageService.saveReflection(updatedEntry);
      _reflections[index] = updatedEntry;
      notifyListeners();
    }
  }

  Future<void> deleteReflection(String id) async {
    await StorageService.deleteReflection(id);
    _reflections.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  ReflectionEntry? getReflectionForDate(DateTime date) {
    try {
      return _reflections.firstWhere(
        (entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  List<DateTime> getDatesWithReflections() {
    return _reflections.map((entry) => entry.date).toList();
  }

  List<ReflectionEntry> getReflectionsForMonth(int year, int month) {
    return _reflections.where((entry) {
      return entry.date.year == year && entry.date.month == month;
    }).toList();
  }

  String getTodayPrompt() {
    return PromptService.getTodayPrompt();
  }

  String getPromptForDate(DateTime date) {
    return PromptService.getPromptForDate(date);
  }

  Future<void> refresh() async {
    _loadReflections();
  }

  static ReflectionsProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<ReflectionsProvider>(context, listen: listen);
  }
}
