import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../utils/safe_provider_base.dart';

class WellnessProvider extends SafeChangeNotifier {
  String? _todaysQuote;
  DateTime? _lastQuoteDate;
  bool _breathingTimerActive = false;
  int _breathingCycle = 0;
  String _breathingPhase = 'Ready';
  bool _disposed = false;

  String? get todaysQuote => _todaysQuote;
  bool get breathingTimerActive => _breathingTimerActive;
  int get breathingCycle => _breathingCycle;
  String get breathingPhase => _breathingPhase;

  final List<String> _inspirationalQuotes = [
    "Every moment is a fresh beginning. - T.S. Eliot",
    "The only way to do great work is to love what you do. - Steve Jobs",
    "Life is what happens to you while you're busy making other plans. - John Lennon",
    "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
    "In the middle of difficulty lies opportunity. - Albert Einstein",
    "Be yourself; everyone else is already taken. - Oscar Wilde",
    "You are never too old to set another goal or to dream a new dream. - C.S. Lewis",
    "The way to get started is to quit talking and begin doing. - Walt Disney",
    "Innovation distinguishes between a leader and a follower. - Steve Jobs",
    "Life is really simple, but we insist on making it complicated. - Confucius",
    "May you live all the days of your life. - Jonathan Swift",
    "Time is precious, but truth is more precious than time. - Benjamin Disraeli",
    "You must be the change you wish to see in the world. - Mahatma Gandhi",
    "Success is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill",
    "The only impossible journey is the one you never begin. - Tony Robbins",
    "What lies behind us and what lies before us are tiny matters compared to what lies within us. - Ralph Waldo Emerson",
    "Believe you can and you're halfway there. - Theodore Roosevelt",
    "The best time to plant a tree was 20 years ago. The second best time is now. - Chinese Proverb",
    "Your time is limited, don't waste it living someone else's life. - Steve Jobs",
    "Happiness is not something ready made. It comes from your own actions. - Dalai Lama",
  ];

  WellnessProvider() {
    _initializeTodaysQuote();
  }

  void _initializeTodaysQuote() {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      _lastQuoteDate = dateOnly;
      final random = Random(dateOnly.millisecondsSinceEpoch);
      _todaysQuote =
          _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
    } catch (e) {
      debugPrint('Error initializing today\'s quote: $e');
      _todaysQuote = _inspirationalQuotes[0];
    }
  }

  String getTodaysQuote() {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      // If it's a new day, update the quote but don't notify during build
      if (_lastQuoteDate != dateOnly) {
        _lastQuoteDate = dateOnly;
        final random = Random(dateOnly.millisecondsSinceEpoch);
        _todaysQuote =
            _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
      }

      return _todaysQuote ?? _inspirationalQuotes[0];
    } catch (e) {
      debugPrint('Error getting today\'s quote: $e');
      return "Every moment is a fresh beginning. - T.S. Eliot";
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      try {
        super.notifyListeners();
      } catch (e) {
        debugPrint('Error in notifyListeners: $e');
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void startBreathingTimer() {
    if (_disposed) return;
    try {
      _breathingTimerActive = true;
      _breathingCycle = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting breathing timer: $e');
    }
  }

  void stopBreathingTimer() {
    if (_disposed) return;
    try {
      _breathingTimerActive = false;
      _breathingPhase = 'Ready';
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping breathing timer: $e');
    }
  }

  void updateBreathingPhase(String phase, int cycle) {
    if (_disposed) return;
    try {
      _breathingPhase = phase;
      _breathingCycle = cycle;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating breathing phase: $e');
    }
  }

  bool get isDisposed => _disposed;
}

class DailyWellnessScreen extends StatefulWidget {
  const DailyWellnessScreen({super.key});

  @override
  State<DailyWellnessScreen> createState() => _DailyWellnessScreenState();
}

class _DailyWellnessScreenState extends State<DailyWellnessScreen>
    with TickerProviderStateMixin, SafeAnimationMixin, SafeStateMixin {
  late AnimationController _quoteFadeController;
  late AnimationController _breathingController;
  late AnimationController _pulseController;

  late Animation<double> _quoteFadeAnimation;
  late Animation<double> _breathingScaleAnimation;
  late Animation<double> _pulseAnimation;
  AudioPlayer? _audioPlayer;
  bool _isPlayingMusic = false;
  bool _breathingActive = false;
  int _currentCycle = 0;
  String _currentPhase = 'Ready';
  Timer? _musicTimer;
  bool _isDisposed = false;
  @override
  void initState() {
    super.initState();

    _quoteFadeController = createSafeAnimationController(
      duration: const Duration(milliseconds: 1000),
      debugLabel: 'Quote Fade',
    );

    _breathingController = createSafeAnimationController(
      duration: const Duration(seconds: 12), // 4s in + 4s hold + 4s out
      debugLabel: 'Breathing',
    );

    _pulseController = createSafeAnimationController(
      duration: const Duration(milliseconds: 1500),
      debugLabel: 'Pulse',
    );

    _quoteFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteFadeController, curve: Curves.easeInOut),
    );

    _breathingScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    try {
      _quoteFadeController.forward();
    } catch (e) {
      debugPrint('Error starting quote animation: $e');
    }

    // Initialize AudioPlayer safely
    try {
      _audioPlayer = AudioPlayer();
    } catch (e) {
      debugPrint('Failed to initialize AudioPlayer: $e');
      _audioPlayer = null;
    }

    _breathingController.addListener(_breathingListener);
  }

  void _breathingListener() {
    if (!_breathingActive || !mounted || _isDisposed) return;

    try {
      final progress = _breathingController.value;
      String newPhase;

      if (progress < 0.33) {
        newPhase = 'Breathe In';
      } else if (progress < 0.66) {
        newPhase = 'Hold';
      } else {
        newPhase = 'Breathe Out';
      }

      if (newPhase != _currentPhase && mounted && !_isDisposed) {
        safeSetState(() {
          _currentPhase = newPhase;
        });
        try {
          HapticFeedback.lightImpact();
        } catch (e) {
          debugPrint('Haptic feedback error: $e');
        }
      }

      if (progress >= 1.0 && mounted && !_isDisposed) {
        safeSetState(() {
          _currentCycle++;
        });
        if (_currentCycle < 5 && _breathingActive && mounted && !_isDisposed) {
          try {
            _breathingController.forward(from: 0.0);
          } catch (e) {
            debugPrint('Error restarting breathing animation: $e');
            _stopBreathing();
          }
        } else {
          _stopBreathing();
        }
      }
    } catch (e) {
      debugPrint('Error in breathing listener: $e');
      if (mounted && !_isDisposed) {
        _stopBreathing();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Cancel any running timers
    _musicTimer?.cancel();

    try {
      _quoteFadeController.dispose();
    } catch (e) {
      debugPrint('Error disposing quote fade controller: $e');
    }

    try {
      _breathingController.removeListener(_breathingListener);
      _breathingController.dispose();
    } catch (e) {
      debugPrint('Error disposing breathing controller: $e');
    }

    try {
      _pulseController.dispose();
    } catch (e) {
      debugPrint('Error disposing pulse controller: $e');
    }

    // Safely dispose audio player
    try {
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
    } catch (e) {
      debugPrint('Error disposing AudioPlayer: $e');
    }

    super.dispose();
  }

  void _startBreathing() async {
    if (!mounted) return;

    try {
      safeSetState(() {
        _breathingActive = true;
        _currentCycle = 0;
        _currentPhase = 'Breathe In';
      });

      try {
        _pulseController.repeat(reverse: true);
      } catch (e) {
        debugPrint('Error starting pulse animation: $e');
      }

      try {
        _breathingController.forward(from: 0.0);
      } catch (e) {
        debugPrint('Error starting breathing animation: $e');
        _stopBreathing();
        return;
      }

      // Start ambient music if available
      if (!_isPlayingMusic && _audioPlayer != null) {
        _toggleMusic();
      }
    } catch (e) {
      debugPrint('Error starting breathing exercise: $e');
      if (mounted) {
        _stopBreathing();
      }
    }
  }

  void _stopBreathing() {
    if (!mounted) return;

    try {
      safeSetState(() {
        _breathingActive = false;
        _currentPhase = 'Complete!';
      });

      try {
        _pulseController.stop();
      } catch (e) {
        debugPrint('Error stopping pulse animation: $e');
      }

      try {
        _breathingController.reset();
      } catch (e) {
        debugPrint('Error resetting breathing animation: $e');
      }

      // Show completion message
      if (mounted && _currentCycle > 0) {
        _showCompletionDialog();
      }
    } catch (e) {
      debugPrint('Error stopping breathing exercise: $e');
    }
  }

  void _toggleMusic() async {
    // Check if disposed or audio player is not available
    if (_isDisposed || _audioPlayer == null) {
      debugPrint('AudioPlayer not available or widget disposed');
      return;
    }

    try {
      if (_isPlayingMusic) {
        _musicTimer?.cancel();
        await _audioPlayer?.stop();
        if (mounted && !_isDisposed) {
          safeSetState(() {
            _isPlayingMusic = false;
          });
        }
      } else {
        // In real app, you'd play an actual audio file
        // await _audioPlayer?.play(AssetSource('audio/relaxing_music.mp3'));
        if (mounted && !_isDisposed) {
          safeSetState(() {
            _isPlayingMusic = true;
          });
        }

        // Simulate stopping after some time for demo
        _musicTimer = Timer(const Duration(seconds: 30), () {
          if (mounted && !_isDisposed && _isPlayingMusic) {
            safeSetState(() {
              _isPlayingMusic = false;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error toggling music: $e');
      if (mounted && !_isDisposed) {
        safeSetState(() {
          _isPlayingMusic = false;
        });
      }
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa, size: 60, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Well Done!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed $_currentCycle breathing cycles. Take a moment to feel the calm.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        Navigator.of(context).pop();
                      } catch (e) {
                        debugPrint('Error closing dialog: $e');
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      debugPrint('Error showing completion dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WellnessProvider(),
      child: Builder(
        builder: (context) {
          try {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.deepPurple,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Daily Wellness',
                        style: TextStyle(color: Colors.white),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple,
                              Colors.deepPurple.withOpacity(0.8),
                              Colors.indigo,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.spa,
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
                        // Daily Quote Section
                        _buildDailyQuoteSection(),
                        const SizedBox(height: 24),

                        // Breathing Timer Section
                        _buildBreathingSection(),
                        const SizedBox(height: 24),

                        // Music Control
                        _buildMusicSection(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            debugPrint('Error building daily wellness screen: $e');
            return Scaffold(
              appBar: AppBar(
                title: const Text('Daily Wellness'),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please try again later.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDailyQuoteSection() {
    return FadeTransition(
      opacity: _quoteFadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade100, Colors.amber.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
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
                  Icons.format_quote,
                  color: Colors.orange.shade600,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Inspiration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<WellnessProvider>(
              builder: (context, provider, child) {
                try {
                  return Text(
                    provider.getTodaysQuote(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  );
                } catch (e) {
                  debugPrint('Error in quote consumer: $e');
                  return const Text(
                    "Every moment is a fresh beginning. - T.S. Eliot",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<WellnessProvider>(
                  builder: (context, provider, child) {
                    try {
                      return ElevatedButton.icon(
                        onPressed: () {
                          try {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(
                              ClipboardData(text: provider.getTodaysQuote()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quote copied to clipboard!'),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Error copying quote: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error copying quote'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error in copy button consumer: $e');
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.air, color: Colors.blue.shade600, size: 28),
              const SizedBox(width: 8),
              Text(
                'Breathing Exercise',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Breathing Circle
          Center(
            child: AnimatedBuilder(
              animation:
                  _breathingActive ? _breathingController : _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      _breathingActive
                          ? _breathingScaleAnimation.value
                          : _pulseAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.shade200,
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPhase,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          if (_breathingActive)
            Text(
              'Cycle: $_currentCycle/5',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 24),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _breathingActive ? _stopBreathing : _startBreathing,
                icon: Icon(_breathingActive ? Icons.stop : Icons.play_arrow),
                label: Text(_breathingActive ? 'Stop' : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _breathingActive ? Colors.red : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.music_note, color: Colors.purple.shade600, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relaxing Music',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPlayingMusic
                      ? 'Playing ambient sounds'
                      : 'Enhance your experience',
                  style: TextStyle(color: Colors.purple.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPlayingMusic,
            onChanged: (value) => _toggleMusic(),
            activeColor: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }
}
