import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/safe_provider_base.dart';

class MoodEntry {
  final DateTime date;
  final int score; // 1-10 scale
  final String description;
  final List<String> triggers;
  final String? note;

  MoodEntry({
    required this.date,
    required this.score,
    required this.description,
    required this.triggers,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'score': score,
    'description': description,
    'triggers': triggers,
    'note': note,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    date: DateTime.parse(json['date']),
    score: json['score'],
    description: json['description'],
    triggers: List<String>.from(json['triggers']),
    note: json['note'],
  );
}

class HealthAnalysis {
  final double overallScore;
  final String trend;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, double> categoryScores;

  HealthAnalysis({
    required this.overallScore,
    required this.trend,
    required this.insights,
    required this.recommendations,
    required this.categoryScores,
  });
}

class MentalHealthProvider extends ChangeNotifier {
  final List<MoodEntry> _moodEntries = [];
  String _selectedPeriod = 'Week';
  final List<String> _availablePeriods = ['Week', 'Month', '3 Months', 'Year'];

  List<MoodEntry> get moodEntries => _moodEntries;
  String get selectedPeriod => _selectedPeriod;
  List<String> get availablePeriods => _availablePeriods;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void addMoodEntry(MoodEntry entry) {
    _moodEntries.add(entry);
    _moodEntries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<MoodEntry> getEntriesForPeriod() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return _moodEntries
        .where((entry) => entry.date.isAfter(startDate))
        .toList();
  }

  double getCurrentScore() {
    final entries = getEntriesForPeriod();
    if (entries.isEmpty) return 0.0;

    final total = entries.fold<double>(0.0, (sum, entry) => sum + entry.score);
    return (total / entries.length) * 10; // Convert to 100 scale
  }

  String getTrend() {
    final entries = getEntriesForPeriod();
    if (entries.length < 2) return 'Not enough data';

    final recent =
        entries
            .take(entries.length ~/ 2)
            .fold<double>(0.0, (sum, entry) => sum + entry.score) /
        (entries.length ~/ 2);
    final older =
        entries
            .skip(entries.length ~/ 2)
            .fold<double>(0.0, (sum, entry) => sum + entry.score) /
        (entries.length - entries.length ~/ 2);

    if (recent > older + 0.5) return 'Improving';
    if (recent < older - 0.5) return 'Declining';
    return 'Stable';
  }

  HealthAnalysis generateAnalysis() {
    final entries = getEntriesForPeriod();
    final score = getCurrentScore();
    final trend = getTrend();

    // Analyze triggers
    final triggerFrequency = <String, int>{};
    for (final entry in entries) {
      for (final trigger in entry.triggers) {
        triggerFrequency[trigger] = (triggerFrequency[trigger] ?? 0) + 1;
      }
    }

    final insights = <String>[];
    final recommendations = <String>[];

    // Generate insights based on score
    if (score >= 80) {
      insights.add('Your mental health is in excellent condition');
      insights.add('You maintain consistent positive mood patterns');
    } else if (score >= 60) {
      insights.add('Your mental health is generally good');
      insights.add('There are some areas for improvement');
    } else if (score >= 40) {
      insights.add('Your mental health needs attention');
      insights.add(
        'Consider seeking support or implementing wellness strategies',
      );
    } else {
      insights.add('Your mental health requires immediate attention');
      insights.add(
        'Please consider speaking with a mental health professional',
      );
    }

    // Generate recommendations
    if (triggerFrequency.containsKey('Stress')) {
      recommendations.add(
        'Practice stress management techniques like deep breathing',
      );
    }
    if (triggerFrequency.containsKey('Sleep')) {
      recommendations.add('Establish a consistent sleep schedule');
    }
    if (triggerFrequency.containsKey('Work')) {
      recommendations.add('Consider work-life balance improvements');
    }

    recommendations.addAll([
      'Maintain regular journaling for self-reflection',
      'Engage in physical activity regularly',
      'Connect with supportive friends and family',
    ]);

    return HealthAnalysis(
      overallScore: score,
      trend: trend,
      insights: insights,
      recommendations: recommendations,
      categoryScores: {
        'Mood': score,
        'Sleep': _calculateCategoryScore(entries, 'Sleep'),
        'Stress': _calculateCategoryScore(entries, 'Stress'),
        'Social': _calculateCategoryScore(entries, 'Social'),
      },
    );
  }

  double _calculateCategoryScore(List<MoodEntry> entries, String category) {
    final relevantEntries =
        entries
            .where(
              (entry) =>
                  entry.triggers.contains(category.toLowerCase()) ||
                  entry.description.toLowerCase().contains(
                    category.toLowerCase(),
                  ),
            )
            .toList();

    if (relevantEntries.isEmpty) return 70.0; // Default neutral score

    final total = relevantEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.score,
    );
    return (total / relevantEntries.length) * 10;
  }

  List<double> getChartData() {
    final entries = getEntriesForPeriod();
    if (entries.isEmpty) return [];

    // Group by day and calculate average
    final Map<String, List<int>> dailyScores = {};

    for (final entry in entries) {
      final dateKey =
          '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      if (!dailyScores.containsKey(dateKey)) {
        dailyScores[dateKey] = [];
      }
      dailyScores[dateKey]!.add(entry.score);
    }

    final sortedDates = dailyScores.keys.toList()..sort();
    return sortedDates.map((date) {
      final scores = dailyScores[date]!;
      return scores.fold<double>(0.0, (sum, score) => sum + score) /
          scores.length;
    }).toList();
  }
}

class MentalHealthScoreScreen extends StatefulWidget {
  const MentalHealthScoreScreen({super.key});

  @override
  State<MentalHealthScoreScreen> createState() =>
      _MentalHealthScoreScreenState();
}

class _MentalHealthScoreScreenState extends State<MentalHealthScoreScreen>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  late AnimationController _animationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    _scoreAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MentalHealthProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mental Health Score'),
          elevation: 0,
          actions: [
            Consumer<MentalHealthProvider>(
              builder: (context, provider, child) {
                return PopupMenuButton<String>(
                  onSelected: provider.setPeriod,
                  itemBuilder: (context) {
                    return provider.availablePeriods.map((period) {
                      return PopupMenuItem(
                        value: period,
                        child: Row(
                          children: [
                            Icon(
                              provider.selectedPeriod == period
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(period),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<MentalHealthProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              provider.selectedPeriod,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<MentalHealthProvider>(
            builder: (context, provider, child) {
              final analysis = provider.generateAnalysis();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(context, analysis),
                    const SizedBox(height: 24),
                    _buildTrendChart(context, provider),
                    const SizedBox(height: 24),
                    _buildCategoryScores(context, analysis),
                    const SizedBox(height: 24),
                    _buildInsights(context, analysis),
                    const SizedBox(height: 24),
                    _buildRecommendations(context, analysis),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMoodEntryDialog(context),
          label: const Text('Log Mood'),
          icon: const Icon(Icons.mood),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, HealthAnalysis analysis) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Mental Health Score',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                final animatedScore =
                    analysis.overallScore * _scoreAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: animatedScore / 100,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(animatedScore),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${animatedScore.toInt()}',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(animatedScore),
                          ),
                        ),
                        Text(
                          _getScoreLabel(animatedScore),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTrendColor(analysis.trend).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTrendIcon(analysis.trend),
                    color: _getTrendColor(analysis.trend),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    analysis.trend,
                    style: TextStyle(
                      color: _getTrendColor(analysis.trend),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, MentalHealthProvider provider) {
    final theme = Theme.of(context);
    final chartData = provider.getChartData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (chartData.isEmpty)
              Container(
                height: 100,
                alignment: Alignment.center,
                child: Text(
                  'No data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: TrendChartPainter(
                    data: chartData,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScores(BuildContext context, HealthAnalysis analysis) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analysis.categoryScores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          '${entry.value.toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(entry.value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(entry.value),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context, HealthAnalysis analysis) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...analysis.insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(insight, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, HealthAnalysis analysis) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...analysis.recommendations.take(3).map((recommendation) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Breathing Exercise',
                    Icons.air,
                    () => _startBreathingExercise(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Meditation',
                    Icons.self_improvement,
                    () => _startMeditation(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Journal Entry',
                    Icons.edit_note,
                    () => _createJournalEntry(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Get Support',
                    Icons.support_agent,
                    () => _getSupport(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'Improving':
        return Colors.green;
      case 'Declining':
        return Colors.red;
      case 'Stable':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'Improving':
        return Icons.trending_up;
      case 'Declining':
        return Icons.trending_down;
      case 'Stable':
        return Icons.trending_flat;
      default:
        return Icons.help;
    }
  }

  void _showMoodEntryDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const MoodEntryDialog());
  }

  void _startBreathingExercise(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting breathing exercise...')),
    );
  }

  void _startMeditation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting guided meditation...')),
    );
  }

  void _createJournalEntry(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _getSupport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mental Health Support'),
            content: const Text(
              'If you\'re experiencing mental health difficulties, please reach out to a qualified professional.\n\n'
              'Crisis Hotline: 988\n'
              'Text "HELLO" to 741741',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class MoodEntryDialog extends StatefulWidget {
  const MoodEntryDialog({super.key});

  @override
  State<MoodEntryDialog> createState() => _MoodEntryDialogState();
}

class _MoodEntryDialogState extends State<MoodEntryDialog> with SafeStateMixin {
  int _selectedMood = 5;
  final List<String> _selectedTriggers = [];
  final _noteController = TextEditingController();

  final List<String> _moodDescriptions = [
    'Terrible',
    'Very Bad',
    'Bad',
    'Poor',
    'Below Average',
    'Average',
    'Good',
    'Very Good',
    'Great',
    'Excellent',
  ];

  final List<String> _triggerOptions = [
    'Stress',
    'Work',
    'Sleep',
    'Social',
    'Health',
    'Family',
    'Money',
    'Weather',
    'Exercise',
    'Food',
    'Other',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Log Your Mood',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mood slider
                    Column(
                      children: [
                        Text(
                          _moodDescriptions[_selectedMood - 1],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _getMoodColor(_selectedMood),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _selectedMood.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _selectedMood.toString(),
                          onChanged: (value) {
                            safeSetState(() => _selectedMood = value.toInt());
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1', style: theme.textTheme.bodySmall),
                            Text('10', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Triggers
                    Text(
                      'What influenced your mood?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _triggerOptions.map((trigger) {
                            final isSelected = _selectedTriggers.contains(
                              trigger,
                            );
                            return FilterChip(
                              label: Text(trigger),
                              selected: isSelected,
                              onSelected: (selected) {
                                safeSetState(() {
                                  if (selected) {
                                    _selectedTriggers.add(trigger);
                                  } else {
                                    _selectedTriggers.remove(trigger);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Note
                    Text(
                      'Additional notes (optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tell us more about your day...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveMoodEntry,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(int mood) {
    if (mood >= 8) return Colors.green;
    if (mood >= 6) return Colors.lightGreen;
    if (mood >= 4) return Colors.orange;
    return Colors.red;
  }

  void _saveMoodEntry() {
    final entry = MoodEntry(
      date: DateTime.now(),
      score: _selectedMood,
      description: _moodDescriptions[_selectedMood - 1],
      triggers: List.from(_selectedTriggers),
      note:
          _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
    );

    context.read<MentalHealthProvider>().addMoodEntry(entry);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mood logged successfully!')));
  }
}

class TrendChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  TrendChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxValue = data.reduce(max);
    final minValue = data.reduce(min);
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
