import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../widgets/voice_note_widget.dart';
import '../widgets/photo_attachment_widget.dart';

class EnhancedMoodTrackerScreen extends StatefulWidget {
  const EnhancedMoodTrackerScreen({super.key});

  @override
  State<EnhancedMoodTrackerScreen> createState() =>
      _EnhancedMoodTrackerScreenState();
}

class _EnhancedMoodTrackerScreenState extends State<EnhancedMoodTrackerScreen>
    with TickerProviderStateMixin {
  MoodType? _selectedMood;
  int _intensity = 3;
  final TextEditingController _notesController = TextEditingController();
  String? _voiceNotePath;
  List<String> _photos = [];
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _moodAnimationController;
  late List<Animation<double>> _moodAnimations;

  final List<String> _triggers = [
    'Work',
    'Family',
    'Friends',
    'Health',
    'Exercise',
    'Sleep',
    'Weather',
    'Food',
    'Money',
    'Travel',
    'Hobby',
    'News',
  ];

  final List<String> _selectedTriggers = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _moodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _moodAnimations = List.generate(
      MoodType.values.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _moodAnimationController,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.5,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    _animationController.forward();
    _moodAnimationController.forward();

    _loadTodayMood();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    _moodAnimationController.dispose();
    super.dispose();
  }

  void _loadTodayMood() {
    final provider = Provider.of<MoodProvider>(context, listen: false);
    final todayMood = provider.getMoodForDate(DateTime.now());

    if (todayMood != null) {
      setState(() {
        _selectedMood = todayMood.mood;
        _intensity = todayMood.intensity;
        _notesController.text = todayMood.notes ?? '';
        // In real implementation, load voice and photos from the mood entry
      });
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<MoodProvider>(context, listen: false);
      final now = DateTime.now();

      final moodEntry = MoodEntry(
        id: 'mood_${now.millisecondsSinceEpoch}',
        date: now,
        mood: _selectedMood!,
        intensity: _intensity,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        createdAt: now,
      );

      await provider.addMood(moodEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Show celebration animation
        _showCelebrationDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save mood'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Great job!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ve logged your mood for today. Keep tracking your emotional journey!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animationController,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'How are you feeling?',
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
                  // Date display
                  _buildDateSection(),
                  const SizedBox(height: 24),

                  // Mood selection
                  _buildMoodSection(),
                  const SizedBox(height: 24),

                  // Intensity slider
                  _buildIntensitySection(),
                  const SizedBox(height: 24),

                  // Mood triggers
                  _buildTriggersSection(),
                  const SizedBox(height: 24),

                  // Voice note
                  VoiceNoteWidget(
                    onVoiceNoteChanged: (path) {
                      setState(() {
                        _voiceNotePath = path;
                      });
                    },
                    initialVoicePath: _voiceNotePath,
                  ),
                  const SizedBox(height: 16),

                  // Photo attachments
                  PhotoAttachmentWidget(
                    onPhotosChanged: (photos) {
                      setState(() {
                        _photos = photos;
                      });
                    },
                    initialPhotos: _photos,
                  ),
                  const SizedBox(height: 24),

                  // Notes section
                  _buildNotesSection(),
                  const SizedBox(height: 32),

                  // Save button
                  _buildSaveButton(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
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
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE').format(DateTime.now()),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('MMMM d, y').format(DateTime.now()),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your mood',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: MoodType.values.length,
          itemBuilder: (context, index) {
            final mood = MoodType.values[index];
            final isSelected = _selectedMood == mood;

            return AnimatedBuilder(
              animation: _moodAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _moodAnimations[index].value,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? _getMoodColor(mood).withOpacity(0.2)
                                : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected
                                  ? _getMoodColor(mood)
                                  : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: _getMoodColor(mood).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getMoodEmoji(mood),
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getMoodName(mood),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isSelected ? _getMoodColor(mood) : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Intensity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_intensity/5',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:
                      _selectedMood != null
                          ? _getMoodColor(_selectedMood!)
                          : Theme.of(context).primaryColor,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor:
                      _selectedMood != null
                          ? _getMoodColor(_selectedMood!)
                          : Theme.of(context).primaryColor,
                  overlayColor:
                      _selectedMood != null
                          ? _getMoodColor(_selectedMood!).withOpacity(0.2)
                          : Theme.of(context).primaryColor.withOpacity(0.2),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _intensity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _intensity = value.round();
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Low', style: Theme.of(context).textTheme.bodySmall),
                  Text('Medium', style: Theme.of(context).textTheme.bodySmall),
                  Text('High', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTriggersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What influenced your mood?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _triggers.map((trigger) {
                final isSelected = _selectedTriggers.contains(trigger);
                return FilterChip(
                  label: Text(trigger),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTriggers.add(trigger);
                      } else {
                        _selectedTriggers.remove(trigger);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional notes',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Container(
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
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'What happened today? How are you feeling?',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors:
              _selectedMood != null
                  ? [
                    _getMoodColor(_selectedMood!),
                    _getMoodColor(_selectedMood!).withOpacity(0.8),
                  ]
                  : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
        ),
        boxShadow: [
          BoxShadow(
            color: (_selectedMood != null
                    ? _getMoodColor(_selectedMood!)
                    : Theme.of(context).primaryColor)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMood,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Save Mood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
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

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.anxious:
        return '😰';
      case MoodType.calm:
        return '😌';
      case MoodType.excited:
        return '🤩';
      case MoodType.peaceful:
        return '☮️';
      case MoodType.stressed:
        return '�';
      case MoodType.content:
        return '😌';
      case MoodType.frustrated:
        return '😤';
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
