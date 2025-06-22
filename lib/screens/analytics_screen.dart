import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../providers/reflections_provider.dart';
import '../providers/goals_provider.dart';
import '../models/mood_entry.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', '3 Months', 'Year'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Duration _getPeriodDuration() {
    switch (_selectedPeriod) {
      case 'Week':
        return const Duration(days: 7);
      case 'Month':
        return const Duration(days: 30);
      case '3 Months':
        return const Duration(days: 90);
      case 'Year':
        return const Duration(days: 365);
      default:
        return const Duration(days: 7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Analytics',
                  style: TextStyle(color: Colors.white),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Period selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Summary cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Mood trends chart
                  _buildMoodTrendsChart(),
                  const SizedBox(height: 24),

                  // Mood distribution pie chart
                  _buildMoodDistributionChart(),
                  const SizedBox(height: 24),

                  // Intensity over time
                  _buildIntensityChart(),
                  const SizedBox(height: 24),

                  // Insights and recommendations
                  _buildInsights(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = _selectedPeriod == period;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer3<MoodProvider, ReflectionsProvider, GoalsProvider>(
      builder: (
        context,
        moodProvider,
        reflectionsProvider,
        goalsProvider,
        child,
      ) {
        final period = _getPeriodDuration();
        final avgIntensity = moodProvider.getAverageMoodIntensity(
          period: period,
        );
        final totalEntries =
            moodProvider.moods
                .where(
                  (mood) => mood.date.isAfter(DateTime.now().subtract(period)),
                )
                .length;

        // Calculate reflection streak
        int reflectionStreak = 0;
        final today = DateTime.now();
        for (int i = 0; i < 30; i++) {
          final date = today.subtract(Duration(days: i));
          final reflection = reflectionsProvider.getReflectionForDate(date);
          if (reflection != null) {
            reflectionStreak++;
          } else {
            break;
          }
        }

        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Mood Entries',
                totalEntries.toString(),
                Icons.mood,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg Intensity',
                avgIntensity.toStringAsFixed(1),
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Streak',
                '${reflectionStreak}d',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendsChart() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final period = _getPeriodDuration();
        final cutoffDate = DateTime.now().subtract(period);
        final moods =
            moodProvider.moods
                .where((mood) => mood.date.isAfter(cutoffDate))
                .toList();

        if (moods.isEmpty) {
          return _buildEmptyChart('No mood data available for this period');
        }

        // Group moods by day and calculate average intensity
        final Map<DateTime, List<MoodEntry>> moodsByDay = {};
        for (final mood in moods) {
          final day = DateTime(mood.date.year, mood.date.month, mood.date.day);
          moodsByDay.putIfAbsent(day, () => []).add(mood);
        }

        final spots =
            moodsByDay.entries.map((entry) {
              final avgIntensity =
                  entry.value.fold<double>(
                    0,
                    (sum, mood) => sum + mood.intensity,
                  ) /
                  entry.value.length;

              final daysSinceStart =
                  entry.key.difference(cutoffDate).inDays.toDouble();
              return FlSpot(daysSinceStart, avgIntensity);
            }).toList();

        spots.sort((a, b) => a.x.compareTo(b.x));

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood Intensity Trend',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: period.inDays / 7,
                          getTitlesWidget: (value, meta) {
                            final date = cutoffDate.add(
                              Duration(days: value.toInt()),
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('M/d').format(date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toInt().toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: period.inDays.toDouble(),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodDistributionChart() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final period = _getPeriodDuration();
        final moodFrequency = moodProvider.getMoodFrequency(period: period);

        if (moodFrequency.isEmpty) {
          return _buildEmptyChart('No mood data available for this period');
        }

        final sections =
            moodFrequency.entries.map((entry) {
              final mood = entry.key;
              final count = entry.value;
              final total = moodFrequency.values.fold<int>(
                0,
                (sum, value) => sum + value,
              );
              final percentage = (count / total * 100);

              return PieChartSectionData(
                color: _getMoodColor(mood),
                value: percentage,
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood Distribution',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          moodFrequency.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getMoodColor(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getMoodName(entry.key),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntensityChart() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final period = _getPeriodDuration();
        final avgIntensity = moodProvider.getAverageMoodIntensity(
          period: period,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Intensity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avgIntensity.toStringAsFixed(1),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'out of 5.0',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Progress indicator
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: avgIntensity / 5,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsights() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final period = _getPeriodDuration();
        final dominantMood = moodProvider.getDominantMood(period: period);
        final avgIntensity = moodProvider.getAverageMoodIntensity(
          period: period,
        );

        final insights = _generateInsights(dominantMood, avgIntensity);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Insights & Recommendations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generateInsights(MoodType? dominantMood, double avgIntensity) {
    final insights = <String>[];

    if (dominantMood != null) {
      switch (dominantMood) {
        case MoodType.happy:
          insights.add(
            'Great job! Your dominant mood is happy. Keep doing what makes you feel good.',
          );
          break;
        case MoodType.sad:
          insights.add(
            'You\'ve been feeling sad lately. Consider talking to someone or engaging in activities you enjoy.',
          );
          break;
        case MoodType.angry:
          insights.add(
            'You\'ve experienced anger frequently. Try stress-relief techniques like deep breathing or exercise.',
          );
          break;
        case MoodType.anxious:
          insights.add(
            'Anxiety has been prominent. Consider mindfulness exercises or speaking with a professional.',
          );
          break;
        case MoodType.calm:
          insights.add(
            'You\'ve been maintaining a calm demeanor. This is excellent for your overall well-being.',
          );
          break;
        case MoodType.excited:
          insights.add(
            'You\'ve been excited! Channel this positive energy into productive activities.',
          );
          break;
        case MoodType.peaceful:
          insights.add(
            'You\'ve been feeling peaceful. This is a wonderful state for reflection and growth.',
          );
          break;
        case MoodType.stressed:
          insights.add(
            'You\'ve been stressed lately. Consider stress-relief techniques and self-care practices.',
          );
          break;
        case MoodType.content:
          insights.add(
            'You\'ve been content, which shows good emotional balance and satisfaction.',
          );
          break;
        case MoodType.frustrated:
          insights.add(
            'Frustration has been prominent. Try to identify the sources and find healthy outlets.',
          );
          break;
      }
    }

    if (avgIntensity < 2.5) {
      insights.add(
        'Your mood intensity has been relatively low. Consider activities that bring you joy and energy.',
      );
    } else if (avgIntensity > 4.0) {
      insights.add(
        'Your emotions have been quite intense. Remember to practice self-care and stress management.',
      );
    } else {
      insights.add(
        'Your emotional intensity is well-balanced. Keep maintaining this healthy emotional state.',
      );
    }

    insights.add(
      'Regular mood tracking helps you understand patterns and triggers. Keep it up!',
    );
    insights.add(
      'Consider setting aside time for activities that consistently improve your mood.',
    );

    return insights;
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.yellow[700]!;
      case MoodType.sad:
        return Colors.blue[700]!;
      case MoodType.angry:
        return Colors.red[700]!;
      case MoodType.anxious:
        return Colors.orange[700]!;
      case MoodType.calm:
        return Colors.green[700]!;
      case MoodType.excited:
        return Colors.purple[700]!;
      case MoodType.peaceful:
        return Colors.teal[700]!;
      case MoodType.stressed:
        return Colors.deepOrange[700]!;
      case MoodType.content:
        return Colors.lightGreen[700]!;
      case MoodType.frustrated:
        return Colors.redAccent[700]!;
    }
  }

  String _getMoodName(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.sad:
        return 'Sad';
      case MoodType.angry:
        return 'Angry';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.calm:
        return 'Calm';
      case MoodType.excited:
        return 'Excited';
      case MoodType.peaceful:
        return 'Peaceful';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.content:
        return 'Content';
      case MoodType.frustrated:
        return 'Frustrated';
    }
  }
}
