import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/safe_provider_base.dart';
import '../providers/reflections_provider.dart';
import '../models/reflection_entry.dart';

class ReflectionDetailScreen extends StatefulWidget {
  final DateTime date;
  final ReflectionEntry? reflection;

  const ReflectionDetailScreen({
    super.key,
    required this.date,
    this.reflection,
  });

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen>
    with SafeStateMixin {
  late TextEditingController _reflectionController;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController(
      text: widget.reflection?.reflection ?? '',
    );
    _isEditing =
        widget.reflection == null; // Edit mode if creating new reflection
    _reflectionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasChanges =
        _reflectionController.text != (widget.reflection?.reflection ?? '');
    if (hasChanges != _hasChanges) {
      safeSetState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _reflectionController.removeListener(_onTextChanged);
    _reflectionController.dispose();
    super.dispose();
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
      if (widget.reflection != null) {
        // Update existing reflection
        await provider.updateReflection(
          id: widget.reflection!.id,
          reflection: _reflectionController.text.trim(),
        );
      } else {
        // Create new reflection
        await provider.addReflection(
          date: widget.date,
          reflection: _reflectionController.text.trim(),
        );
      }

      safeSetState(() {
        _isEditing = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved successfully!')),
      );

      // Pop with result to indicate success
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save reflection')),
      );
    }
  }

  Future<void> _deleteReflection() async {
    if (widget.reflection == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reflection'),
            content: const Text(
              'Are you sure you want to delete this reflection? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final provider = Provider.of<ReflectionsProvider>(context, listen: false);
      try {
        await provider.deleteReflection(widget.reflection!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reflection deleted successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete reflection')),
          );
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Changes'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(widget.date);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.reflection != null ? 'Edit Reflection' : 'New Reflection',
          ),
          centerTitle: true,
          actions: [
            if (widget.reflection != null && !_isEditing)
              IconButton(
                onPressed: () {
                  safeSetState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit),
                tooltip: 'Edit reflection',
              ),
            if (widget.reflection != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteReflection();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
              ),
          ],
        ),
        body: SingleChildScrollView(
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
                  final prompt =
                      widget.reflection?.prompt ??
                      provider.getPromptForDate(widget.date);

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
                                'Prompt',
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

              // Reflection content
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
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_isEditing) ...[
                        TextField(
                          controller: _reflectionController,
                          decoration: const InputDecoration(
                            hintText:
                                'Write your thoughts and feelings here...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 12,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (widget.reflection != null)
                              TextButton(
                                onPressed: () {
                                  safeSetState(() {
                                    _isEditing = false;
                                    _reflectionController.text =
                                        widget.reflection!.reflection;
                                    _hasChanges = false;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            if (widget.reflection != null)
                              const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: _saveReflection,
                                child: Text(
                                  widget.reflection != null ? 'Update' : 'Save',
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
                            widget.reflection!.reflection,
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
                              'Written at ${DateFormat('h:mm a').format(widget.reflection!.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            if (widget.reflection!.updatedAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• Updated at ${DateFormat('h:mm a').format(widget.reflection!.updatedAt!)}',
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
            ],
          ),
        ),
      ),
    );
  }
}
