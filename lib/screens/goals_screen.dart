import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_entry.dart';
import '../providers/goals_provider.dart';
import '../providers/premium_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Goals & Dreams'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Active', icon: Icon(Icons.flag)),
                Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _showAddGoalDialog(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildActiveGoalsTab(), _buildCompletedGoalsTab()],
          ),
        );
      },
    );
  }

  Widget _buildActiveGoalsTab() {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final activeGoals = goalsProvider.activeGoals;

        if (activeGoals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.flag_outlined,
            title: 'No Active Goals',
            subtitle: 'Set your first goal and start your journey!',
            actionText: 'Add Goal',
            onAction: () => _showAddGoalDialog(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            final goal = activeGoals[index];
            return _buildGoalCard(goal);
          },
        );
      },
    );
  }

  Widget _buildCompletedGoalsTab() {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final completedGoals = goalsProvider.completedGoals;

        if (completedGoals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'No Completed Goals',
            subtitle: 'Complete your first goal to see it here!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return _buildGoalCard(goal);
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalEntry goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.category.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          decoration:
                              goal.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      Text(
                        goal.category.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            goal.isCompleted
                                ? 'Mark Incomplete'
                                : 'Mark Complete',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                  onSelected:
                      (value) => _handleGoalAction(goal, value.toString()),
                ),
              ],
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (goal.deadline != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM d, y').format(goal.deadline!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (goal.milestones.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Progress: ${goal.completedMilestones.length}/${goal.milestones.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ],
            if (goal.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...goal.milestones.map(
                (milestone) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: goal.completedMilestones.contains(milestone),
                        onChanged: (value) => _toggleMilestone(goal, milestone),
                      ),
                      Expanded(
                        child: Text(
                          milestone,
                          style: TextStyle(
                            decoration:
                                goal.completedMilestones.contains(milestone)
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleGoalAction(GoalEntry goal, String action) async {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        _showEditGoalDialog(goal);
        break;
      case 'toggle':
        try {
          await goalsProvider.toggleGoalCompletion(goal.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                goal.isCompleted
                    ? 'Goal marked as incomplete'
                    : 'Congratulations! Goal completed! 🎉',
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating goal: $e')));
        }
        break;
      case 'delete':
        _showDeleteGoalDialog(goal);
        break;
    }
  }

  void _toggleMilestone(GoalEntry goal, String milestone) async {
    try {
      await Provider.of<GoalsProvider>(
        context,
        listen: false,
      ).toggleMilestone(goal.id, milestone);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating milestone: $e')));
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    _showGoalDialog(context, 'Add New Goal', null);
  }

  void _showEditGoalDialog(GoalEntry goal) {
    _showGoalDialog(context, 'Edit Goal', goal);
  }

  void _showGoalDialog(BuildContext context, String title, GoalEntry? goal) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final descriptionController = TextEditingController(
      text: goal?.description ?? '',
    );
    GoalCategory selectedCategory = goal?.category ?? GoalCategory.personal;
    DateTime? deadline = goal?.deadline;
    List<String> milestones = List.from(goal?.milestones ?? []);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<GoalCategory>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              GoalCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Text(category.icon),
                                      const SizedBox(width: 8),
                                      Text(category.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            deadline != null
                                ? 'Due: ${DateFormat('MMM d, y').format(deadline!)}'
                                : 'No deadline',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        deadline ??
                                        DateTime.now().add(
                                          const Duration(days: 30),
                                        ),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365 * 5),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() => deadline = date);
                                  }
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              if (deadline != null)
                                IconButton(
                                  onPressed:
                                      () => setState(() => deadline = null),
                                  icon: const Icon(Icons.clear),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Milestones'),
                                const Spacer(),
                                IconButton(
                                  onPressed:
                                      () => _showAddMilestoneDialog(
                                        context,
                                        milestones,
                                        setState,
                                      ),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            ...milestones.map(
                              (milestone) => ListTile(
                                title: Text(milestone),
                                trailing: IconButton(
                                  onPressed:
                                      () => setState(
                                        () => milestones.remove(milestone),
                                      ),
                                  icon: const Icon(Icons.delete),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          () => _saveGoal(
                            context,
                            goal,
                            titleController.text,
                            descriptionController.text,
                            selectedCategory,
                            deadline,
                            milestones,
                          ),
                      child: Text(goal == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddMilestoneDialog(
    BuildContext context,
    List<String> milestones,
    StateSetter setState,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Milestone'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Milestone',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() => milestones.add(controller.text.trim()));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _saveGoal(
    BuildContext context,
    GoalEntry? existingGoal,
    String title,
    String description,
    GoalCategory category,
    DateTime? deadline,
    List<String> milestones,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    try {
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

      if (existingGoal == null) {
        // Adding new goal
        final goal = GoalEntry(
          id: const Uuid().v4(),
          title: title.trim(),
          description: description.trim(),
          createdAt: DateTime.now(),
          deadline: deadline,
          category: category,
          milestones: milestones,
        );
        await goalsProvider.addGoal(goal);
      } else {
        // Updating existing goal
        final updatedGoal = existingGoal.copyWith(
          title: title.trim(),
          description: description.trim(),
          deadline: deadline,
          category: category,
          milestones: milestones,
        );
        await goalsProvider.updateGoal(updatedGoal);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingGoal == null ? 'Goal added!' : 'Goal updated!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving goal: $e')));
    }
  }

  void _showDeleteGoalDialog(GoalEntry goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Goal'),
            content: Text('Are you sure you want to delete "${goal.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await Provider.of<GoalsProvider>(
                      context,
                      listen: false,
                    ).deleteGoal(goal.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goal deleted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting goal: $e')),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
