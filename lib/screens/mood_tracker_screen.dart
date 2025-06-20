import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../providers/premium_provider.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (!premiumProvider.canUseMoodTracking) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Mood Tracker'),
              centerTitle: true,
            ),
            body: _buildPremiumRequired(context, premiumProvider),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mood Tracker'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today', icon: Icon(Icons.today)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                Tab(text: 'History', icon: Icon(Icons.history)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(),
              _buildAnalyticsTab(),
              _buildHistoryTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumRequired(
    BuildContext context,
    PremiumProvider premiumProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '🌟 Premium Feature',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Track your mood daily and see beautiful analytics to understand your emotional patterns better.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => premiumProvider.showPremiumDialog(context),
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final todayMood = moodProvider.getMoodForDate(_selectedDate);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 24),
              if (todayMood == null) ...[
                _buildMoodSelector(),
              ] else ...[
                _buildMoodDisplay(todayMood),
                const SizedBox(height: 16),
                _buildEditButton(todayMood),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              icon: const Icon(Icons.edit_calendar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: MoodType.values.length,
              itemBuilder: (context, index) {
                final mood = MoodType.values[index];
                return _buildMoodCard(mood);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(MoodType mood) {
    return Card(
      child: InkWell(
        onTap: () => _showMoodIntensityDialog(mood),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mood.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodIntensityDialog(MoodType mood) {
    int intensity = 3;
    String notes = '';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      Text(mood.emoji),
                      const SizedBox(width: 8),
                      Text(mood.displayName),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'How intense is this feeling?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => intensity = value),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    intensity == value
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    color:
                                        intensity == value
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'What triggered this feeling?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => notes = value,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => _saveMood(mood, intensity, notes),
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _saveMood(MoodType mood, int intensity, String notes) async {
    try {
      final moodEntry = MoodEntry(
        id: const Uuid().v4(),
        date: _selectedDate,
        mood: mood,
        intensity: intensity,
        notes: notes.isEmpty ? null : notes,
        createdAt: DateTime.now(),
      );

      await Provider.of<MoodProvider>(
        context,
        listen: false,
      ).addMood(moodEntry);

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mood saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving mood: $e')));
    }
  }

  Widget _buildMoodDisplay(MoodEntry mood) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mood.mood.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.mood.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Intensity: ${mood.intensity}/5',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (mood.notes != null) ...[
              const SizedBox(height: 12),
              Text('Notes:', style: Theme.of(context).textTheme.bodySmall),
              Text(mood.notes!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(MoodEntry mood) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showMoodIntensityDialog(mood.mood),
        icon: const Icon(Icons.edit),
        label: const Text('Edit Mood'),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final weekMoods = moodProvider.getMoodsForWeek(DateTime.now());
        final monthMoods = moodProvider.getMoodsForMonth(DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodChart(weekMoods),
              const SizedBox(height: 24),
              _buildMoodFrequencyChart(monthMoods),
              const SizedBox(height: 24),
              _buildInsightCards(moodProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodChart(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No mood data for this week',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Mood Intensity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: 6 - value.toInt()),
                          );
                          return Text(DateFormat('E').format(date));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 1,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getMoodSpots(moods),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getMoodSpots(List<MoodEntry> moods) {
    final spots = <FlSpot>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final mood =
          moods.where((m) {
            return m.date.day == date.day &&
                m.date.month == date.month &&
                m.date.year == date.year;
          }).firstOrNull;

      if (mood != null) {
        spots.add(FlSpot(i.toDouble(), mood.intensity.toDouble()));
      }
    }

    return spots;
  }

  Widget _buildMoodFrequencyChart(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No mood data for this month',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final frequency = <MoodType, int>{};
    for (final mood in moods) {
      frequency[mood.mood] = (frequency[mood.mood] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Mood Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...frequency.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(entry.key.emoji),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key.displayName)),
                    Text('${entry.value}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards(MoodProvider moodProvider) {
    final avgIntensity = moodProvider.getAverageMoodIntensity(
      period: const Duration(days: 30),
    );
    final dominantMood = moodProvider.getDominantMood(
      period: const Duration(days: 30),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average Intensity',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        avgIntensity.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        dominantMood?.emoji ?? '😐',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dominant Mood',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        dominantMood?.displayName ?? 'None',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final moods = moodProvider.moods;

        if (moods.isEmpty) {
          return const Center(child: Text('No mood entries yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            final mood = moods[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Text(
                  mood.mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(mood.mood.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Intensity: ${mood.intensity}/5'),
                    Text(DateFormat('MMM d, y').format(mood.date)),
                    if (mood.notes != null) Text(mood.notes!),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteMood(mood);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteMood(MoodEntry mood) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Mood Entry'),
            content: const Text(
              'Are you sure you want to delete this mood entry?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await Provider.of<MoodProvider>(
                      context,
                      listen: false,
                    ).deleteMood(mood.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mood entry deleted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting mood: $e')),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
