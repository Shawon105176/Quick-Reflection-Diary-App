import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/safe_provider_base.dart';
import '../providers/reflections_provider.dart';
import '../models/reflection_entry.dart';
import '../widgets/app_logo.dart';
import '../widgets/stats_card_widget.dart';
import '../widgets/quick_mood_selector.dart';
import '../widgets/daily_inspiration.dart';
import '../widgets/recent_reflections.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin, SafeStateMixin {
  ReflectionEntry? _todayReflection;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodayReflection();

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
    _reflectionController.dispose();
    super.dispose();
  }

  void _loadTodayReflection() {
    final provider = Provider.of<ReflectionsProvider>(context, listen: false);
    _todayReflection = provider.getReflectionForDate(DateTime.now());

    // Update the text controller with existing reflection
    if (_todayReflection != null) {
      _reflectionController.text = _todayReflection!.reflection;
    }
  }

  Future<void> _saveReflection() async {
    final content = _reflectionController.text.trim();
    if (content.isEmpty) return;

    final provider = Provider.of<ReflectionsProvider>(context, listen: false);

    if (_todayReflection == null) {
      // Create new reflection
      await provider.addReflection(date: DateTime.now(), reflection: content);
      // Reload to get the new reflection
      _loadTodayReflection();
    } else {
      // Update existing reflection
      await provider.updateReflection(
        id: _todayReflection!.id,
        reflection: content,
      );
      // Update local instance
      _todayReflection = _todayReflection!.copyWith(
        reflection: content,
        updatedAt: DateTime.now(),
      );
    }

    safeSetState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _todayReflection == null
              ? 'Reflection saved!'
              : 'Reflection updated!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteReflection() async {
    if (_todayReflection == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reflection'),
            content: const Text(
              'Are you sure you want to delete today\'s reflection?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ReflectionsProvider>(context, listen: false);
      await provider.deleteReflection(_todayReflection!.id);
      _reflectionController.clear();
      _todayReflection = null;
      safeSetState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflection deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(today);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 32, showBackground: false),
                  const SizedBox(width: 12),
                  Text(
                    'Mindful',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Stats Cards
                  const StatsCardWidget(),

                  // Quick Mood Selector
                  const QuickMoodSelector(),

                  // Daily Inspiration
                  const DailyInspiration(),

                  // Today's Reflection Card
                  _buildTodaysReflectionCard(theme, formattedDate),

                  // Recent Reflections
                  const RecentReflections(),

                  // Bottom spacing
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysReflectionCard(ThemeData theme, String formattedDate) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Reflection',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reflection input
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _reflectionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          _todayReflection == null
                              ? 'How was your day? What are you grateful for?\n\nShare your thoughts, feelings, and experiences...'
                              : 'Update your reflection...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveReflection,
                        icon: Icon(
                          _todayReflection == null
                              ? Icons.save_rounded
                              : Icons.update_rounded,
                        ),
                        label: Text(
                          _todayReflection == null
                              ? 'Save Reflection'
                              : 'Update Reflection',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    if (_todayReflection != null) ...[
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _deleteReflection,
                        icon: const Icon(Icons.delete_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
