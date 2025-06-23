import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NightModeTimerScreen extends StatefulWidget {
  const NightModeTimerScreen({super.key});

  @override
  State<NightModeTimerScreen> createState() => _NightModeTimerScreenState();
}

class _NightModeTimerScreenState extends State<NightModeTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NightModeTimerProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Night Mode Timer'),
          centerTitle: true,
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.indigo.shade900,
        body: Consumer<NightModeTimerProvider>(
          builder: (context, provider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header with moon icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade800,
                            Colors.indigo.shade900,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Icon(
                                  Icons.nightlight_round,
                                  size: 80,
                                  color: Colors.amber.shade200,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sleep Mode Timer',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set a timer to automatically switch to dark mode for better sleep',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Timer Settings Card
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timer, color: Colors.amber.shade200),
                                const SizedBox(width: 12),
                                const Text(
                                  'Timer Settings',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Enable/Disable Switch
                            SwitchListTile(
                              title: const Text(
                                'Enable Night Mode Timer',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                provider.isEnabled
                                    ? 'Timer is active'
                                    : 'Timer is disabled',
                                style: TextStyle(color: Colors.white70),
                              ),
                              value: provider.isEnabled,
                              activeColor: Colors.amber.shade200,
                              onChanged: (value) {
                                provider.toggleTimer(value);
                              },
                            ),

                            if (provider.isEnabled) ...[
                              const Divider(color: Colors.white30),

                              // Start Time Picker
                              ListTile(
                                leading: Icon(
                                  Icons.bedtime,
                                  color: Colors.amber.shade200,
                                ),
                                title: const Text(
                                  'Bedtime',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  provider.startTime.format(context),
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap:
                                    () => _selectTime(context, provider, true),
                              ),

                              // End Time Picker
                              ListTile(
                                leading: Icon(
                                  Icons.wb_sunny,
                                  color: Colors.amber.shade200,
                                ),
                                title: const Text(
                                  'Wake Time',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  provider.endTime.format(context),
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap:
                                    () => _selectTime(context, provider, false),
                              ),

                              const Divider(color: Colors.white30),

                              // Quick Timer Options
                              const Text(
                                'Quick Setup',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildQuickTimerChip(
                                    '8 hours',
                                    () => provider.setQuickTimer(8),
                                    provider,
                                  ),
                                  _buildQuickTimerChip(
                                    '6 hours',
                                    () => provider.setQuickTimer(6),
                                    provider,
                                  ),
                                  _buildQuickTimerChip(
                                    '4 hours',
                                    () => provider.setQuickTimer(4),
                                    provider,
                                  ),
                                  _buildQuickTimerChip(
                                    'Sunset to Sunrise',
                                    () => provider.setSunsetSunriseTimer(),
                                    provider,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Status Card
                    if (provider.isEnabled)
                      Card(
                        color: Colors.white.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber.shade200,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Current Status',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatusRow(
                                'Timer Status',
                                provider.isActive ? 'Active' : 'Waiting',
                                provider.isActive
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              _buildStatusRow(
                                'Current Time',
                                TimeOfDay.now().format(context),
                                Colors.blue,
                              ),
                              _buildStatusRow(
                                'Next Switch',
                                provider.getNextSwitchTime(),
                                Colors.purple,
                              ),
                              if (provider.timeRemaining.isNotEmpty)
                                _buildStatusRow(
                                  'Time Remaining',
                                  provider.timeRemaining,
                                  Colors.cyan,
                                ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Tips Card
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber.shade200,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sleep Tips',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...provider.sleepTips.map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber.shade200,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickTimerChip(
    String label,
    VoidCallback onTap,
    NightModeTimerProvider provider,
  ) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white.withOpacity(0.1),
      side: BorderSide(color: Colors.amber.shade200),
      onPressed: onTap,
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    NightModeTimerProvider provider,
    bool isStartTime,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? provider.startTime : provider.endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber.shade200,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      if (isStartTime) {
        provider.setStartTime(time);
      } else {
        provider.setEndTime(time);
      }
    }
  }
}

class NightModeTimerProvider extends ChangeNotifier {
  bool _isEnabled = false;
  bool _isActive = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0); // 10 PM
  TimeOfDay _endTime = const TimeOfDay(hour: 6, minute: 0); // 6 AM
  String _timeRemaining = '';

  bool get isEnabled => _isEnabled;
  bool get isActive => _isActive;
  TimeOfDay get startTime => _startTime;
  TimeOfDay get endTime => _endTime;
  String get timeRemaining => _timeRemaining;

  final List<String> sleepTips = [
    'Dark mode reduces blue light exposure, helping your body produce melatonin naturally.',
    'Try to avoid screens 1 hour before your bedtime for better sleep quality.',
    'Keep your bedroom cool, dark, and quiet for optimal sleep conditions.',
    'Establish a consistent sleep schedule, even on weekends.',
    'Consider writing in your journal before bed to clear your mind.',
  ];

  void toggleTimer(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      _startTimer();
    } else {
      _stopTimer();
    }
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    if (_isEnabled) {
      _startTimer();
    }
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    if (_isEnabled) {
      _startTimer();
    }
    notifyListeners();
  }

  void setQuickTimer(int hours) {
    final now = TimeOfDay.now();
    _startTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    _endTime = TimeOfDay(hour: (now.hour + 1 + hours) % 24, minute: 0);
    if (_isEnabled) {
      _startTimer();
    }
    notifyListeners();
  }

  void setSunsetSunriseTimer() {
    // Approximate sunset/sunrise times (would use location API in production)
    _startTime = const TimeOfDay(hour: 19, minute: 0); // 7 PM
    _endTime = const TimeOfDay(hour: 7, minute: 0); // 7 AM
    if (_isEnabled) {
      _startTimer();
    }
    notifyListeners();
  }

  void _startTimer() {
    _isActive = _isInNightModeTime();
    _updateTimeRemaining();
    // In a real app, you would set up actual timers here
  }

  void _stopTimer() {
    _isActive = false;
    _timeRemaining = '';
  }

  bool _isInNightModeTime() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (startMinutes < endMinutes) {
      // Same day (e.g., 10 PM to 11 PM)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Crosses midnight (e.g., 10 PM to 6 AM)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  String getNextSwitchTime() {
    if (!_isEnabled) return 'Timer disabled';

    if (_isActive) {
      return 'Switch to light mode at ${_formatTime(_endTime)}';
    } else {
      return 'Switch to dark mode at ${_formatTime(_startTime)}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _updateTimeRemaining() {
    if (!_isEnabled) {
      _timeRemaining = '';
      return;
    }

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final targetTime = _isActive ? _endTime : _startTime;
    final targetMinutes = targetTime.hour * 60 + targetTime.minute;

    int remainingMinutes;
    if (_isActive && targetMinutes < nowMinutes) {
      // End time is tomorrow
      remainingMinutes = (24 * 60) - nowMinutes + targetMinutes;
    } else if (!_isActive && targetMinutes < nowMinutes) {
      // Start time is tomorrow
      remainingMinutes = (24 * 60) - nowMinutes + targetMinutes;
    } else {
      remainingMinutes = targetMinutes - nowMinutes;
    }

    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    if (hours > 0) {
      _timeRemaining = '${hours}h ${minutes}m';
    } else {
      _timeRemaining = '${minutes}m';
    }
  }
}
