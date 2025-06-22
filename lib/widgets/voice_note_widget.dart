import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class VoiceNoteWidget extends StatefulWidget {
  final Function(String?) onVoiceNoteChanged;
  final String? initialVoicePath;

  const VoiceNoteWidget({
    super.key,
    required this.onVoiceNoteChanged,
    this.initialVoicePath,
  });

  @override
  State<VoiceNoteWidget> createState() => _VoiceNoteWidgetState();
}

class _VoiceNoteWidgetState extends State<VoiceNoteWidget>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  Duration _recordDuration = Duration.zero;
  Duration _playDuration = Duration.zero;
  String? _voicePath;

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  // Simulated recording timer
  DateTime? _recordStartTime;

  @override
  void initState() {
    super.initState();
    _voicePath = widget.initialVoicePath;
    _hasRecording = _voicePath != null;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Start periodic update for recording duration
    _startDurationTimer();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isRecording && _recordStartTime != null) {
        setState(() {
          _recordDuration = DateTime.now().difference(_recordStartTime!);
        });
      }
      return mounted;
    });
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _recordStartTime = DateTime.now();
        _recordDuration = Duration.zero;
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat(reverse: true);

      // Simulate recording - in real implementation, use record package
      // final record = AudioRecorder();
      // await record.start(const RecordConfig(), path: path);
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _hasRecording = true;
        _recordStartTime = null;
      });

      _pulseController.stop();
      _waveController.stop();

      // Simulate saving recording
      _voicePath =
          'path/to/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      widget.onVoiceNoteChanged(_voicePath);

      // In real implementation:
      // await record.stop();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_voicePath == null) return;

    try {
      setState(() {
        _isPlaying = true;
        _playDuration = Duration.zero;
      });

      _waveController.repeat(reverse: true);

      // Simulate playback - in real implementation, use audioplayers package
      // final player = AudioPlayer();
      // await player.play(DeviceFileSource(_voicePath!));

      // Simulate 3-second playback
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isPlaying = false;
      });

      _waveController.stop();
    } catch (e) {
      debugPrint('Error playing recording: $e');
      setState(() {
        _isPlaying = false;
      });
      _waveController.stop();
    }
  }

  Future<void> _deleteRecording() async {
    setState(() {
      _hasRecording = false;
      _voicePath = null;
      _recordDuration = Duration.zero;
      _playDuration = Duration.zero;
    });

    widget.onVoiceNoteChanged(null);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Voice Note',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (_hasRecording && !_isRecording)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: _deleteRecording,
                  color: Colors.red[400],
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (!_hasRecording && !_isRecording) ...[
            // Record button when no recording exists
            _buildRecordButton(),
          ] else if (_isRecording) ...[
            // Recording interface
            _buildRecordingInterface(),
          ] else if (_hasRecording) ...[
            // Playback interface
            _buildPlaybackInterface(),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _startRecording,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        ),
        child: Icon(Icons.mic, size: 32, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Column(
      children: [
        // Animated recording button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: const Icon(Icons.stop, size: 32, color: Colors.red),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Recording timer
        Text(
          _formatDuration(_recordDuration),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),

        const SizedBox(height: 8),

        // Recording indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Recording...'),
          ],
        ),

        const SizedBox(height: 16),

        // Animated waveform
        _buildAnimatedWaveform(),
      ],
    );
  }

  Widget _buildPlaybackInterface() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: _isPlaying ? null : _playRecording,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _isPlaying
                          ? Colors.grey.withOpacity(0.3)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color:
                        _isPlaying
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 28,
                  color:
                      _isPlaying ? Colors.grey : Theme.of(context).primaryColor,
                ),
              ),
            ),

            // Duration display
            Column(
              children: [
                Text(
                  _formatDuration(_recordDuration),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Voice Note',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),

        if (_isPlaying) ...[
          const SizedBox(height: 16),
          _buildAnimatedWaveform(),
        ],
      ],
    );
  }

  Widget _buildAnimatedWaveform() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            final height =
                20.0 +
                (10.0 *
                    (1 + 0.5 * (1 + (index * 0.2) % 1) * _waveAnimation.value));

            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color:
                    _isRecording
                        ? Colors.red.withOpacity(0.7)
                        : Theme.of(context).primaryColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
