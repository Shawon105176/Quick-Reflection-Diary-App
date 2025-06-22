import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/reflections_provider.dart';
import '../models/mood_entry.dart';

class StatsCardWidget extends StatelessWidget {
  const StatsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodProvider, ReflectionsProvider>(
      builder: (context, moodProvider, reflectionsProvider, child) {
        final theme = Theme.of(context);
        final moods = moodProvider.moods;
        final reflections = reflectionsProvider.reflections;

        // Calculate stats
        final weekMoods = moodProvider.getMoodsForWeek(DateTime.now());
        final avgMood =
            weekMoods.isEmpty
                ? 0.0
                : weekMoods.fold(0, (sum, mood) => sum + mood.intensity) /
                    weekMoods.length;
        final streakCount = _calculateStreak(reflections);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Week Average',
                  '${avgMood.toStringAsFixed(1)}/5',
                  Icons.trending_up,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Current Streak',
                  '$streakCount days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Entries',
                  '${reflections.length}',
                  Icons.book,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List reflections) {
    if (reflections.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      DateTime checkDate = today.subtract(Duration(days: i));
      bool hasEntry = reflections.any((reflection) {
        return reflection.date.year == checkDate.year &&
            reflection.date.month == checkDate.month &&
            reflection.date.day == checkDate.day;
      });

      if (hasEntry) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
