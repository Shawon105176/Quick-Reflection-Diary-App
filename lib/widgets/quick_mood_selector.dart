import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import 'package:uuid/uuid.dart';

class QuickMoodSelector extends StatefulWidget {
  const QuickMoodSelector({super.key});

  @override
  State<QuickMoodSelector> createState() => _QuickMoodSelectorState();
}

class _QuickMoodSelectorState extends State<QuickMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  MoodType? _selectedMood;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Check if today's mood already exists
    _checkTodaysMood();
  }

  void _checkTodaysMood() {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final todaysMood = moodProvider.getMoodForDate(DateTime.now());
    if (todaysMood != null) {
      setState(() {
        _selectedMood = todaysMood.mood;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children:
                  MoodType.values
                      .map((mood) => _buildMoodButton(mood))
                      .toList(),
            ),
          ),
          if (_selectedMood != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mood logged for today: ${_getMoodName(_selectedMood!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodButton(MoodType mood) {
    final theme = Theme.of(context);
    final isSelected = _selectedMood == mood;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _selectMood(mood),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            _getMoodColor(mood),
                            _getMoodColor(mood).withOpacity(0.7),
                          ],
                        )
                        : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected
                          ? _getMoodColor(mood)
                          : theme.colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: _getMoodColor(mood).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMoodEmoji(mood),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _getMoodName(mood),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectMood(MoodType mood) async {
    setState(() {
      _selectedMood = mood;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Save mood
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final today = DateTime.now();

    // Check if mood already exists for today
    final existingMood = moodProvider.getMoodForDate(today);

    if (existingMood != null) {
      // Update existing mood
      final updatedMood = MoodEntry(
        id: existingMood.id,
        mood: mood,
        intensity: 3, // Default intensity
        date: today,
        notes: existingMood.notes,
        createdAt: existingMood.createdAt,
      );
      await moodProvider.updateMood(updatedMood);
    } else {
      // Create new mood entry
      final newMood = MoodEntry(
        id: _uuid.v4(),
        mood: mood,
        intensity: 3, // Default intensity
        date: today,
        notes: '',
        createdAt: today,
      );
      await moodProvider.addMood(newMood);
    }

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood "${_getMoodName(mood)}" saved!'),
          backgroundColor: _getMoodColor(mood),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '�';
      case MoodType.calm:
        return '�';
      case MoodType.content:
        return '😌';
      case MoodType.peaceful:
        return '�️';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.anxious:
        return '😰';
      case MoodType.stressed:
        return '😵';
      case MoodType.frustrated:
        return '�';
    }
  }

  String _getMoodName(MoodType mood) {
    return mood.toString().split('.').last.toUpperCase();
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.green;
      case MoodType.excited:
        return Colors.pink;
      case MoodType.calm:
        return Colors.teal;
      case MoodType.content:
        return Colors.lightGreen;
      case MoodType.peaceful:
        return Colors.lightBlue;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.angry:
        return Colors.red;
      case MoodType.anxious:
        return Colors.orange;
      case MoodType.stressed:
        return Colors.deepOrange;
      case MoodType.frustrated:
        return Colors.redAccent;
    }
  }
}
