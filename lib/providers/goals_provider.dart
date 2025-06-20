import 'package:flutter/material.dart';
import '../models/goal_entry.dart';
import '../services/storage_service.dart';

class GoalsProvider extends ChangeNotifier {
  List<GoalEntry> _goals = [];
  bool _isLoading = false;

  List<GoalEntry> get goals => _goals;
  List<GoalEntry> get activeGoals =>
      _goals.where((goal) => !goal.isCompleted).toList();
  List<GoalEntry> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();
  bool get isLoading => _isLoading;

  GoalsProvider() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = StorageService.getAllGoals();
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(GoalEntry goal) async {
    try {
      await StorageService.saveGoal(goal);
      _goals.insert(0, goal);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding goal: $e');
      rethrow;
    }
  }

  Future<void> updateGoal(GoalEntry goal) async {
    try {
      await StorageService.saveGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await StorageService.deleteGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      rethrow;
    }
  }

  Future<void> toggleGoalCompletion(String goalId) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedGoal = goal.copyWith(isCompleted: !goal.isCompleted);
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      debugPrint('Error toggling goal completion: $e');
      rethrow;
    }
  }

  Future<void> addMilestone(String goalId, String milestone) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final newMilestones = List<String>.from(goal.milestones)
          ..add(milestone);
        final updatedGoal = goal.copyWith(milestones: newMilestones);
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      debugPrint('Error adding milestone: $e');
      rethrow;
    }
  }

  Future<void> toggleMilestone(String goalId, String milestone) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final completedMilestones = List<String>.from(goal.completedMilestones);

        if (completedMilestones.contains(milestone)) {
          completedMilestones.remove(milestone);
        } else {
          completedMilestones.add(milestone);
        }

        final updatedGoal = goal.copyWith(
          completedMilestones: completedMilestones,
        );
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      debugPrint('Error toggling milestone: $e');
      rethrow;
    }
  }

  List<GoalEntry> getGoalsByCategory(GoalCategory category) {
    return _goals.where((goal) => goal.category == category).toList();
  }

  List<GoalEntry> getGoalsWithUpcomingDeadlines({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _goals.where((goal) {
      return goal.deadline != null &&
          goal.deadline!.isBefore(cutoffDate) &&
          !goal.isCompleted;
    }).toList();
  }

  double getOverallProgress() {
    if (_goals.isEmpty) return 0.0;

    final totalProgress = _goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.progress,
    );

    return totalProgress / _goals.length;
  }

  Map<GoalCategory, int> getCategoryDistribution() {
    final distribution = <GoalCategory, int>{};
    for (final goal in _goals) {
      distribution[goal.category] = (distribution[goal.category] ?? 0) + 1;
    }
    return distribution;
  }
}
