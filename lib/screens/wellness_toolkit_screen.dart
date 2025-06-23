import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/safe_provider_base.dart';

class WellnessToolkitProvider extends SafeChangeNotifier {
  List<String> _gratitudeList = [];
  int _stressLevel = 3;
  int _journalGoalMinutes = 5;
  int _todayJournalMinutes = 0;
  String? _todayAffirmation;
  DateTime? _lastAffirmationDate;

  List<String> get gratitudeList => _gratitudeList;
  int get stressLevel => _stressLevel;
  int get journalGoalMinutes => _journalGoalMinutes;
  int get todayJournalMinutes => _todayJournalMinutes;
  String? get todayAffirmation => _todayAffirmation;

  final List<String> _affirmations = [
    "I am capable of amazing things.",
    "I choose to focus on what I can control.",
    "I am worthy of love and respect.",
    "Every challenge is an opportunity to grow.",
    "I trust in my ability to overcome obstacles.",
    "I am grateful for this moment.",
    "I radiate positivity and confidence.",
    "I am exactly where I need to be.",
    "I choose peace over worry.",
    "I am proud of my progress.",
    "I deserve happiness and success.",
    "I am resilient and strong.",
    "I choose to see the good in every situation.",
    "I am in charge of my thoughts and emotions.",
    "I am creating a life I love.",
    "I trust the process of life.",
    "I am enough, just as I am.",
    "I choose courage over comfort.",
    "I am open to new possibilities.",
    "I celebrate my unique journey.",
  ];

  void addGratitude(String gratitude) {
    _gratitudeList.add(gratitude);
    notifyListeners();
  }

  void removeGratitude(int index) {
    if (index >= 0 && index < _gratitudeList.length) {
      _gratitudeList.removeAt(index);
      notifyListeners();
    }
  }

  void updateStressLevel(int level) {
    _stressLevel = level;
    notifyListeners();
  }

  void setJournalGoal(int minutes) {
    _journalGoalMinutes = minutes;
    notifyListeners();
  }

  void addJournalTime(int minutes) {
    _todayJournalMinutes += minutes;
    notifyListeners();
  }

  String generateAffirmation() {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    if (_lastAffirmationDate != dateOnly) {
      _lastAffirmationDate = dateOnly;
      final random = Random(dateOnly.millisecondsSinceEpoch);
      _todayAffirmation = _affirmations[random.nextInt(_affirmations.length)];
      notifyListeners();
    }

    return _todayAffirmation!;
  }

  double get journalProgress =>
      _journalGoalMinutes > 0
          ? (_todayJournalMinutes / _journalGoalMinutes).clamp(0.0, 1.0)
          : 0.0;

  bool get journalGoalAchieved => _todayJournalMinutes >= _journalGoalMinutes;
}

class WellnessToolkitScreen extends StatefulWidget {
  const WellnessToolkitScreen({super.key});

  @override
  State<WellnessToolkitScreen> createState() => _WellnessToolkitScreenState();
}

class _WellnessToolkitScreenState extends State<WellnessToolkitScreen>
    with TickerProviderStateMixin, SafeStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _progressAnimationController;
  late List<AnimationController> _cardAnimationControllers;

  final TextEditingController _gratitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardAnimationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );

    _mainAnimationController.forward();
    _progressAnimationController.forward();

    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _cardAnimationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _progressAnimationController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Wellness Toolkit',
                style: TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal,
                      Colors.teal.withOpacity(0.8),
                      Colors.cyan,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Journal Goal Progress
                _buildJournalGoalCard(),
                const SizedBox(height: 16),

                // Quick Tools Grid
                _buildQuickToolsGrid(),
                const SizedBox(height: 16),

                // Gratitude List
                _buildGratitudeSection(),
                const SizedBox(height: 16),

                // Stress Level
                _buildStressLevelSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalGoalCard() {
    return Consumer<WellnessToolkitProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _cardAnimationControllers[0],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimationControllers[0].value)),
              child: Opacity(
                opacity: _cardAnimationControllers[0].value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade100, Colors.teal.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.green.shade600,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Journal Goal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const Spacer(),
                          if (provider.journalGoalAchieved)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.todayJournalMinutes}/${provider.journalGoalMinutes} minutes',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedBuilder(
                                  animation: _progressAnimationController,
                                  builder: (context, child) {
                                    return LinearProgressIndicator(
                                      value:
                                          provider.journalProgress *
                                          _progressAnimationController.value,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        provider.journalGoalAchieved
                                            ? Colors.green
                                            : Colors.teal,
                                      ),
                                      minHeight: 8,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          CircularProgressIndicator(
                            value: provider.journalProgress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              provider.journalGoalAchieved
                                  ? Colors.green
                                  : Colors.teal,
                            ),
                            strokeWidth: 6,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  () =>
                                      _showGoalSettingDialog(context, provider),
                              icon: const Icon(Icons.edit),
                              label: const Text('Set Goal'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.addJournalTime(5);
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added 5 minutes!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Log Time'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickToolsGrid() {
    return Consumer<WellnessToolkitProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _cardAnimationControllers[1],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimationControllers[1].value)),
              child: Opacity(
                opacity: _cardAnimationControllers[1].value,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickTool(
                      'Daily Affirmation',
                      Icons.psychology,
                      Colors.purple,
                      () => _showAffirmationDialog(context, provider),
                    ),
                    _buildQuickTool(
                      'Stress Check',
                      Icons.favorite,
                      Colors.red,
                      () => _showStressDialog(context, provider),
                    ),
                    _buildQuickTool(
                      'Mood Booster',
                      Icons.emoji_emotions,
                      Colors.orange,
                      () => _showMoodBoosterDialog(context),
                    ),
                    _buildQuickTool(
                      'Quick Gratitude',
                      Icons.favorite_border,
                      Colors.pink,
                      () => _showQuickGratitudeDialog(context, provider),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickTool(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGratitudeSection() {
    return Consumer<WellnessToolkitProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _cardAnimationControllers[2],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimationControllers[2].value)),
              child: Opacity(
                opacity: _cardAnimationControllers[2].value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.pink.shade50, Colors.pink.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.pink.shade600,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gratitude List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed:
                                () =>
                                    _showAddGratitudeDialog(context, provider),
                            icon: Icon(Icons.add, color: Colors.pink.shade600),
                          ),
                        ],
                      ),

                      if (provider.gratitudeList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Add your first gratitude entry',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ...provider.gratitudeList.asMap().entries.map((entry) {
                          int index = entry.key;
                          String gratitude = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.pink.shade400,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      gratitude,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => provider.removeGratitude(index),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStressLevelSection() {
    return Consumer<WellnessToolkitProvider>(
      builder: (context, provider, child) {
        return AnimatedBuilder(
          animation: _cardAnimationControllers[3],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimationControllers[3].value)),
              child: Opacity(
                opacity: _cardAnimationControllers[3].value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.indigo.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: Colors.blue.shade600,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Stress Level',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Text(
                            'Low',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                          Expanded(
                            child: Slider(
                              value: provider.stressLevel.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              activeColor: _getStressColor(
                                provider.stressLevel,
                              ),
                              onChanged: (value) {
                                provider.updateStressLevel(value.round());
                                HapticFeedback.lightImpact();
                              },
                            ),
                          ),
                          Text(
                            'High',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ],
                      ),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${provider.stressLevel}/10',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _getStressColor(provider.stressLevel),
                              ),
                            ),
                            Text(
                              _getStressLabel(provider.stressLevel),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getStressColor(provider.stressLevel),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (provider.stressLevel > 6)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Consider taking a break, doing breathing exercises, or talking to someone.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getStressLabel(int level) {
    if (level <= 2) return 'Very Relaxed';
    if (level <= 4) return 'Calm';
    if (level <= 6) return 'Moderate';
    if (level <= 8) return 'Stressed';
    return 'Very Stressed';
  }

  void _showGoalSettingDialog(
    BuildContext context,
    WellnessToolkitProvider provider,
  ) {
    int tempGoal = provider.journalGoalMinutes;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Daily Journal Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current goal: ${provider.journalGoalMinutes} minutes'),
                const SizedBox(height: 16),
                Slider(
                  value: tempGoal.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 11,
                  label: '$tempGoal minutes',
                  onChanged: (value) {
                    safeSetState(() {
                      tempGoal = value.round();
                    });
                  },
                ),
                Text('New goal: $tempGoal minutes'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.setJournalGoal(tempGoal);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showAffirmationDialog(
    BuildContext context,
    WellnessToolkitProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology, size: 60, color: Colors.purple),
                const SizedBox(height: 16),
                const Text(
                  'Today\'s Affirmation',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.generateAffirmation(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Thank You',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showStressDialog(
    BuildContext context,
    WellnessToolkitProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quick Stress Check'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How stressed are you feeling right now?'),
                const SizedBox(height: 16),
                Slider(
                  value: provider.stressLevel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getStressColor(provider.stressLevel),
                  onChanged:
                      (value) => provider.updateStressLevel(value.round()),
                ),
                Text(
                  '${provider.stressLevel}/10 - ${_getStressLabel(provider.stressLevel)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  void _showMoodBoosterDialog(BuildContext context) {
    final List<String> boosterTips = [
      '🌟 Take 5 deep breaths',
      '🚶 Go for a short walk',
      '🎵 Listen to your favorite song',
      '💧 Drink a glass of water',
      '🌱 Look at something green',
      '😊 Smile at yourself in the mirror',
      '📱 Text someone you care about',
      '☀️ Step outside for fresh air',
    ];

    final randomTip = boosterTips[Random().nextInt(boosterTips.length)];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_emotions,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mood Booster',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  randomTip,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'I\'ll try it!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showQuickGratitudeDialog(
    BuildContext context,
    WellnessToolkitProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quick Gratitude'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('What\'s one thing you\'re grateful for right now?'),
                const SizedBox(height: 16),
                TextField(
                  controller: _gratitudeController,
                  decoration: const InputDecoration(
                    hintText: 'I\'m grateful for...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_gratitudeController.text.trim().isNotEmpty) {
                    provider.addGratitude(_gratitudeController.text.trim());
                    _gratitudeController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to gratitude list!')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showAddGratitudeDialog(
    BuildContext context,
    WellnessToolkitProvider provider,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Gratitude'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'What are you grateful for?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    provider.addGratitude(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
