import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reflections_provider.dart';
import '../models/reflection_entry.dart';
import '../widgets/voice_note_widget.dart';
import '../widgets/photo_attachment_widget.dart';
import '../utils/safe_provider_base.dart';

class EnhancedReflectionScreen extends StatefulWidget {
  final ReflectionEntry? existingReflection;
  final DateTime? selectedDate;

  const EnhancedReflectionScreen({
    super.key,
    this.existingReflection,
    this.selectedDate,
  });

  @override
  State<EnhancedReflectionScreen> createState() =>
      _EnhancedReflectionScreenState();
}

class _EnhancedReflectionScreenState extends State<EnhancedReflectionScreen>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  final TextEditingController _reflectionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _voiceNotePath;
  List<String> _photos = [];
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _writeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _writeAnimation;

  final List<String> _prompts = [
    "What are you grateful for today?",
    "What challenged you today, and how did you handle it?",
    "Describe a moment that made you smile today.",
    "What would you like to improve about today?",
    "What did you learn about yourself today?",
    "How did you show kindness today?",
    "What are you looking forward to tomorrow?",
    "What emotions did you experience today?",
    "What was the highlight of your day?",
    "How did you take care of yourself today?",
  ];

  String _selectedPrompt = '';
  int _wordCount = 0;
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingData();
    _selectRandomPrompt();

    _reflectionController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    try {
      _animationController = createSafeAnimationController(
        duration: const Duration(milliseconds: 1200),
      );

      _writeAnimationController = createSafeAnimationController(
        duration: const Duration(milliseconds: 2000),
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );

      _writeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _writeAnimationController,
          curve: Curves.easeInOut,
        ),
      );

      _animationController.forward();
    } catch (e) {
      debugPrint('Error setting up animations: $e');
    }
  }

  void _loadExistingData() {
    if (widget.existingReflection != null) {
      _reflectionController.text = widget.existingReflection!.reflection;
      // In real implementation, load voice notes and photos
    }
  }

  void _selectRandomPrompt() {
    _prompts.shuffle();
    _selectedPrompt = _prompts.first;
  }

  void _updateWordCount() {
    final text = _reflectionController.text;
    final words = text.trim().split(RegExp(r'\s+'));
    safeSetState(() {
      _wordCount = text.trim().isEmpty ? 0 : words.length;
    });

    // Start writing animation when user starts typing
    if (text.isNotEmpty && !_writeAnimationController.isAnimating) {
      _writeAnimationController.repeat(reverse: true);
    } else if (text.isEmpty) {
      _writeAnimationController.stop();
      _writeAnimationController.reset();
    }
  }

  Future<void> _saveReflection() async {
    if (_reflectionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your reflection first')),
      );
      return;
    }

    safeSetState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReflectionsProvider>(context, listen: false);
      final date = widget.selectedDate ?? DateTime.now();

      if (widget.existingReflection != null) {
        await provider.updateReflection(
          id: widget.existingReflection!.id,
          reflection: _reflectionController.text.trim(),
        );
      } else {
        await provider.addReflection(
          date: date,
          reflection: _reflectionController.text.trim(),
          customPrompt: _selectedPrompt,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reflection saved successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to view reflection
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save reflection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      safeSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.selectedDate ?? DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Daily Reflection',
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
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _writeAnimation,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_wordCount words',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 0.7 + (_writeAnimation.value * 0.3),
                                  child: child,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shuffle, color: Colors.white),
                  onPressed: _selectRandomPrompt,
                  tooltip: 'New prompt',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildPromptSection(),
                  ),
                  const SizedBox(height: 24),

                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildReflectionInput(),
                  ),
                  const SizedBox(height: 24),

                  SlideTransition(
                    position: _slideAnimation,
                    child: VoiceNoteWidget(
                      onVoiceNoteChanged: (path) {
                        safeSetState(() {
                          _voiceNotePath = path;
                        });
                      },
                      initialVoicePath: _voiceNotePath,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SlideTransition(
                    position: _slideAnimation,
                    child: PhotoAttachmentWidget(
                      onPhotosChanged: (photos) {
                        safeSetState(() {
                          _photos = photos;
                        });
                      },
                      initialPhotos: _photos,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildSaveButton(),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reflection Prompt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  safeSetState(() {
                    _selectRandomPrompt();
                  });
                },
                tooltip: 'New prompt',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedPrompt,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).primaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionInput() {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Reflection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _focusNode.hasFocus
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _reflectionController,
              focusNode: _focusNode,
              maxLines: 12,
              minLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Take a moment to reflect on your day...\n\nWhat happened? How did you feel? What did you learn?',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(color: Colors.grey[500], height: 1.5),
              ),
              style: const TextStyle(fontSize: 16, height: 1.6),
              textInputAction: TextInputAction.newline,
              onChanged: (text) {
                safeSetState(() {
                  // This will trigger _updateWordCount via the listener
                });
              },
            ),
          ),

          // Writing tips
          if (_reflectionController.text.isEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Writing Tips:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                        'Be honest with yourself',
                        'Include specific details',
                        'Mention emotions you felt',
                        'Note any lessons learned',
                      ]
                      .map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(color: Colors.blue),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.blue[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveReflection,
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
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.existingReflection != null
                          ? 'Update Reflection'
                          : 'Save Reflection',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
