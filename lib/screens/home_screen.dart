import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reflections_provider.dart';
import '../models/reflection_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _reflectionController = TextEditingController();
  bool _isEditing = false;
  ReflectionEntry? _todayReflection;

  @override
  void initState() {
    super.initState();
    _loadTodayReflection();
  }

  void _loadTodayReflection() {
    final provider = Provider.of<ReflectionsProvider>(context, listen: false);
    _todayReflection = provider.getReflectionForDate(DateTime.now());

    if (_todayReflection != null) {
      _reflectionController.text = _todayReflection!.reflection;
    }
  }

  Future<void> _saveReflection() async {
    if (_reflectionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your reflection first')),
      );
      return;
    }

    final provider = Provider.of<ReflectionsProvider>(context, listen: false);

    try {
      if (_todayReflection != null) {
        // Update existing reflection
        await provider.updateReflection(
          id: _todayReflection!.id,
          reflection: _reflectionController.text.trim(),
        );
      } else {
        // Create new reflection
        await provider.addReflection(
          date: DateTime.now(),
          reflection: _reflectionController.text.trim(),
        );
      }

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved successfully!')),
      );

      _loadTodayReflection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save reflection')),
      );
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Reflection'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ReflectionsProvider>(
            context,
            listen: false,
          ).refresh();
          _loadTodayReflection();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Prompt card
              Consumer<ReflectionsProvider>(
                builder: (context, provider, child) {
                  final prompt = provider.getTodayPrompt();

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Today\'s Prompt',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            prompt,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Reflection input card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Reflection',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_todayReflection != null && !_isEditing)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit reflection',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_isEditing || _todayReflection == null) ...[
                        TextField(
                          controller: _reflectionController,
                          decoration: const InputDecoration(
                            hintText:
                                'Write your thoughts and feelings here...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_isEditing) ...[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    if (_todayReflection != null) {
                                      _reflectionController.text =
                                          _todayReflection!.reflection;
                                    }
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: FilledButton(
                                onPressed: _saveReflection,
                                child: Text(
                                  _todayReflection != null ? 'Update' : 'Save',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _todayReflection!.reflection,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Written at ${DateFormat('h:mm a').format(_todayReflection!.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            if (_todayReflection!.updatedAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• Updated at ${DateFormat('h:mm a').format(_todayReflection!.updatedAt!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Quote or tip
              const SizedBox(height: 24),
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"The unexamined life is not worth living." - Socrates',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing for better scrolling
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
