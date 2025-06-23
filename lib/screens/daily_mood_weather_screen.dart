import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../utils/safe_provider_base.dart';

class MoodWeatherData {
  final String mood;
  final String weather;
  final String temperature;
  final String location;
  final DateTime timestamp;
  final String note;

  MoodWeatherData({
    required this.mood,
    required this.weather,
    required this.temperature,
    required this.location,
    required this.timestamp,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'weather': weather,
    'temperature': temperature,
    'location': location,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };

  factory MoodWeatherData.fromJson(Map<String, dynamic> json) =>
      MoodWeatherData(
        mood: json['mood'],
        weather: json['weather'],
        temperature: json['temperature'],
        location: json['location'],
        timestamp: DateTime.parse(json['timestamp']),
        note: json['note'],
      );
}

class DailyMoodWeatherProvider extends SafeChangeNotifier {
  final List<MoodWeatherData> _entries = [];
  MoodWeatherData? _todayEntry;
  bool _isLoading = false;
  Map<String, String>? _cachedWeather;

  List<MoodWeatherData> get entries => _entries;
  MoodWeatherData? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;
  Map<String, String>? get cachedWeather => _cachedWeather;

  // Mock weather data - in production, integrate with weather API
  final List<Map<String, String>> _mockWeatherData = [
    {'weather': 'Sunny', 'temp': '72°F', 'icon': '☀️'},
    {'weather': 'Cloudy', 'temp': '68°F', 'icon': '☁️'},
    {'weather': 'Rainy', 'temp': '64°F', 'icon': '🌧️'},
    {'weather': 'Snowy', 'temp': '32°F', 'icon': '❄️'},
    {'weather': 'Partly Cloudy', 'temp': '70°F', 'icon': '⛅'},
  ];

  void addEntry(MoodWeatherData entry) {
    _entries.add(entry);
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Check if this is today's entry
    final today = DateTime.now();
    if (entry.timestamp.year == today.year &&
        entry.timestamp.month == today.month &&
        entry.timestamp.day == today.day) {
      _todayEntry = entry;
    }

    notifyListeners();
  }

  Future<Map<String, String>> getCurrentWeather() async {
    // If we already have cached weather data, return it immediately
    if (_cachedWeather != null) {
      return _cachedWeather!;
    }

    // Set loading state safely
    if (!_isLoading) {
      _isLoading = true;
      // Use scheduleMicrotask to ensure this runs after the current frame
      scheduleMicrotask(() => notifyListeners());
    }

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock weather data
      final random = Random();
      final weatherData =
          _mockWeatherData[random.nextInt(_mockWeatherData.length)];

      // Cache the weather data
      _cachedWeather = weatherData;

      return weatherData;
    } catch (e) {
      debugPrint('Error getting weather: $e');
      // Return default weather data on error
      return _mockWeatherData.first;
    } finally {
      // Always reset loading state
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
    }
  }

  // Method to refresh weather data
  void refreshWeather() {
    _cachedWeather = null;
    getCurrentWeather();
  }

  bool hasTodayEntry() {
    final today = DateTime.now();
    return _entries.any(
      (entry) =>
          entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day,
    );
  }

  List<MoodWeatherData> getEntriesForWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries.where((entry) => entry.timestamp.isAfter(weekAgo)).toList();
  }

  Map<String, int> getMoodCorrelations() {
    final correlations = <String, int>{};

    for (final entry in _entries) {
      final key = '${entry.mood}-${entry.weather}';
      correlations[key] = (correlations[key] ?? 0) + 1;
    }

    return correlations;
  }
}

class DailyMoodWeatherWidget extends StatelessWidget {
  const DailyMoodWeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DailyMoodWeatherProvider(),
      child: const _DailyMoodWeatherContent(),
    );
  }
}

class _DailyMoodWeatherContent extends StatefulWidget {
  const _DailyMoodWeatherContent();

  @override
  State<_DailyMoodWeatherContent> createState() =>
      _DailyMoodWeatherContentState();
}

class _DailyMoodWeatherContentState extends State<_DailyMoodWeatherContent>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();

    // Initialize animation controller with error handling
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      );
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      // Start animation after a small delay to ensure widget is mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.forward();
        }
      });
    } catch (e) {
      debugPrint('Error initializing animations: $e');
    }
  }

  @override
  void dispose() {
    try {
      _animationController.dispose();
    } catch (e) {
      debugPrint('Error disposing animation controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Vibe'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showVibeHistory(context),
            icon: const Icon(Icons.history),
            tooltip: 'View History',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTodayVibeCard(context),
              ),
              const SizedBox(height: 24),
              _buildWeatherCard(context),
              const SizedBox(height: 24),
              _buildMoodInsights(context),
              const SizedBox(height: 24),
              _buildRecentEntries(context),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<DailyMoodWeatherProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed:
                provider.hasTodayEntry()
                    ? null
                    : () => _showMoodWeatherDialog(context),
            label: Text(provider.hasTodayEntry() ? 'Logged Today' : 'Log Vibe'),
            icon: Icon(
              provider.hasTodayEntry() ? Icons.check : Icons.add_reaction,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayVibeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DailyMoodWeatherProvider>(
      builder: (context, provider, child) {
        if (provider.todayEntry == null) {
          return Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to capture today\'s vibe?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log your mood along with today\'s weather',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(
                        0.8,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final entry = provider.todayEntry!;
        return Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  _getMoodColor(entry.mood).withOpacity(0.2),
                  _getMoodColor(entry.mood).withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          _getMoodEmoji(entry.mood),
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.mood,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 60,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          _getWeatherEmoji(entry.weather),
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.weather,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.temperature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.note,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Weather',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<DailyMoodWeatherProvider>(
              builder: (context, provider, child) {
                // Check if we have cached weather first
                if (provider.cachedWeather != null) {
                  return _buildWeatherDisplay(
                    context,
                    provider.cachedWeather!,
                    provider,
                  );
                }

                // If loading, show loading indicator
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Use FutureBuilder for initial load only
                return FutureBuilder<Map<String, String>>(
                  future: provider.getCurrentWeather(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return _buildWeatherDisplay(
                        context,
                        snapshot.data!,
                        provider,
                      );
                    }

                    return Text(
                      'Unable to load weather data',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(
    BuildContext context,
    Map<String, String> weather,
    DailyMoodWeatherProvider provider,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(weather['icon'] ?? '🌤️', style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather['weather'] ?? 'Unknown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weather['temp'] ?? '--°F',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed:
              () => _showMoodWeatherDialog(context, initialWeather: weather),
          child: const Text('Log Mood'),
        ),
      ],
    );
  }

  Widget _buildMoodInsights(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DailyMoodWeatherProvider>(
      builder: (context, provider, child) {
        final correlations = provider.getMoodCorrelations();

        if (correlations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Mood & Weather Insights',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'You tend to feel happier on sunny days and more reflective when it\'s cloudy.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Track more days to discover your personal weather-mood patterns!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentEntries(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DailyMoodWeatherProvider>(
      builder: (context, provider, child) {
        final recentEntries = provider.getEntriesForWeek();

        if (recentEntries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...recentEntries.take(3).map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMoodColor(
                        entry.mood,
                      ).withOpacity(0.2),
                      child: Text(
                        _getMoodEmoji(entry.mood),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      '${entry.mood} • ${entry.weather}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${_formatDate(entry.timestamp)} • ${entry.temperature}',
                    ),
                    trailing: Text(
                      _getWeatherEmoji(entry.weather),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }).toList(),
            if (recentEntries.length > 3)
              TextButton(
                onPressed: () => _showVibeHistory(context),
                child: Text('View all ${recentEntries.length} entries'),
              ),
          ],
        );
      },
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return Colors.yellow;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return Colors.green;
      case 'sad':
      case 'down':
      case 'melancholy':
        return Colors.blue;
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return Colors.red;
      case 'anxious':
      case 'worried':
      case 'nervous':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'joyful':
        return '😄';
      case 'excited':
        return '🤩';
      case 'calm':
        return '😌';
      case 'peaceful':
        return '😇';
      case 'relaxed':
        return '😎';
      case 'sad':
        return '😢';
      case 'down':
        return '😔';
      case 'melancholy':
        return '😞';
      case 'angry':
        return '😠';
      case 'frustrated':
        return '😤';
      case 'irritated':
        return '😒';
      case 'anxious':
        return '😰';
      case 'worried':
        return '😟';
      case 'nervous':
        return '😬';
      default:
        return '😐';
    }
  }

  String _getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      case 'stormy':
        return '⛈️';
      case 'foggy':
        return '🌫️';
      case 'windy':
        return '💨';
      default:
        return '🌤️';
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  void _showMoodWeatherDialog(
    BuildContext context, {
    Map<String, String>? initialWeather,
  }) {
    showDialog(
      context: context,
      builder: (context) => MoodWeatherDialog(initialWeather: initialWeather),
    );
  }

  void _showVibeHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const VibeHistoryScreen()));
  }
}

class MoodWeatherDialog extends StatefulWidget {
  final Map<String, String>? initialWeather;

  const MoodWeatherDialog({super.key, this.initialWeather});

  @override
  State<MoodWeatherDialog> createState() => _MoodWeatherDialogState();
}

class _MoodWeatherDialogState extends State<MoodWeatherDialog>
    with SafeStateMixin {
  String _selectedMood = '';
  String _selectedWeather = '';
  String _temperature = '';
  final _noteController = TextEditingController();

  final List<String> _moods = [
    'Happy',
    'Joyful',
    'Excited',
    'Calm',
    'Peaceful',
    'Relaxed',
    'Sad',
    'Down',
    'Melancholy',
    'Angry',
    'Frustrated',
    'Irritated',
    'Anxious',
    'Worried',
    'Nervous',
  ];

  final List<String> _weatherOptions = [
    'Sunny',
    'Cloudy',
    'Partly Cloudy',
    'Rainy',
    'Snowy',
    'Stormy',
    'Foggy',
    'Windy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialWeather != null) {
      _selectedWeather = widget.initialWeather!['weather']!;
      _temperature = widget.initialWeather!['temp']!;
    }
  }

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
                    '🌈 Log Today\'s Vibe',
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
                    // Mood Selection
                    Text(
                      'How are you feeling?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _moods.map((mood) {
                            final isSelected = _selectedMood == mood;
                            return FilterChip(
                              label: Text('${_getMoodEmoji(mood)} $mood'),
                              selected: isSelected,
                              onSelected: (selected) {
                                safeSetState(() => _selectedMood = mood);
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Weather Selection
                    Text(
                      'What\'s the weather like?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _weatherOptions.map((weather) {
                            final isSelected = _selectedWeather == weather;
                            return FilterChip(
                              label: Text(
                                '${_getWeatherEmoji(weather)} $weather',
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                safeSetState(() => _selectedWeather = weather);
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Temperature
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Temperature',
                        hintText: 'e.g., 72°F',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _temperature = value,
                      controller: TextEditingController(text: _temperature),
                    ),
                    const SizedBox(height: 16),

                    // Note
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'How does the weather make you feel?',
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
                    onPressed: _canSave() ? _saveEntry : null,
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

  bool _canSave() {
    return _selectedMood.isNotEmpty &&
        _selectedWeather.isNotEmpty &&
        _temperature.isNotEmpty;
  }

  void _saveEntry() {
    final entry = MoodWeatherData(
      mood: _selectedMood,
      weather: _selectedWeather,
      temperature: _temperature,
      location: 'Current Location', // In production, get actual location
      timestamp: DateTime.now(),
      note: _noteController.text.trim(),
    );

    context.read<DailyMoodWeatherProvider>().addEntry(entry);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Today\'s vibe logged successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'joyful':
        return '😄';
      case 'excited':
        return '🤩';
      case 'calm':
        return '😌';
      case 'peaceful':
        return '😇';
      case 'relaxed':
        return '😎';
      case 'sad':
        return '😢';
      case 'down':
        return '😔';
      case 'melancholy':
        return '😞';
      case 'angry':
        return '😠';
      case 'frustrated':
        return '😤';
      case 'irritated':
        return '😒';
      case 'anxious':
        return '😰';
      case 'worried':
        return '😟';
      case 'nervous':
        return '😬';
      default:
        return '😐';
    }
  }

  String _getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      case 'stormy':
        return '⛈️';
      case 'foggy':
        return '🌫️';
      case 'windy':
        return '💨';
      default:
        return '🌤️';
    }
  }
}

class VibeHistoryScreen extends StatelessWidget {
  const VibeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vibe History'), elevation: 0),
      body: Consumer<DailyMoodWeatherProvider>(
        builder: (context, provider, child) {
          final entries = provider.entries;

          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryCard(context, entry);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌈', style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            'No Vibes Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your daily mood and weather\nto see patterns over time',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, MoodWeatherData entry) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getMoodColor(entry.mood).withOpacity(0.2),
                  child: Text(
                    _getMoodEmoji(entry.mood),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.mood} • ${entry.weather}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatDate(entry.timestamp)} • ${entry.temperature}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getWeatherEmoji(entry.weather),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            if (entry.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return Colors.yellow;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return Colors.green;
      case 'sad':
      case 'down':
      case 'melancholy':
        return Colors.blue;
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return Colors.red;
      case 'anxious':
      case 'worried':
      case 'nervous':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'joyful':
        return '😄';
      case 'excited':
        return '🤩';
      case 'calm':
        return '😌';
      case 'peaceful':
        return '😇';
      case 'relaxed':
        return '😎';
      case 'sad':
        return '😢';
      case 'down':
        return '😔';
      case 'melancholy':
        return '😞';
      case 'angry':
        return '😠';
      case 'frustrated':
        return '😤';
      case 'irritated':
        return '😒';
      case 'anxious':
        return '😰';
      case 'worried':
        return '😟';
      case 'nervous':
        return '😬';
      default:
        return '😐';
    }
  }

  String _getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      case 'stormy':
        return '⛈️';
      case 'foggy':
        return '🌫️';
      case 'windy':
        return '💨';
      default:
        return '🌤️';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
