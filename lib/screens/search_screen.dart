import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reflections_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/goals_provider.dart';
import '../models/reflection_entry.dart';
import '../models/mood_entry.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filters = ['All', 'Reflections', 'Moods', 'Goals'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final reflectionsProvider = Provider.of<ReflectionsProvider>(
      context,
      listen: false,
    );
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    List<dynamic> results = []; // Search in reflections
    if (_selectedFilter == 'All' || _selectedFilter == 'Reflections') {
      final reflections =
          reflectionsProvider.reflections
              .where(
                (reflection) =>
                    reflection.reflection.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    reflection.prompt.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
      results.addAll(reflections);
    }

    // Search in moods
    if (_selectedFilter == 'All' || _selectedFilter == 'Moods') {
      final moods =
          moodProvider.moods
              .where(
                (mood) =>
                    mood.notes?.toLowerCase().contains(query.toLowerCase()) ==
                        true ||
                    mood.mood.toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
      results.addAll(moods);
    }

    // Search in goals
    if (_selectedFilter == 'All' || _selectedFilter == 'Goals') {
      final goals =
          goalsProvider.goals
              .where(
                (goal) =>
                    goal.title.toLowerCase().contains(query.toLowerCase()) ||
                    goal.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
      results.addAll(goals);
    }

    // Sort by date (most recent first)
    results.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      if (a is ReflectionEntry) {
        dateA = a.date;
      } else if (a is MoodEntry) {
        dateA = a.date;
      } else {
        dateA = (a as dynamic).createdAt ?? DateTime.now();
      }

      if (b is ReflectionEntry) {
        dateB = b.date;
      } else if (b is MoodEntry) {
        dateB = b.date;
      } else {
        dateB = (b as dynamic).createdAt ?? DateTime.now();
      }

      return dateB.compareTo(dateA);
    });

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search your thoughts, moods, and goals...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Filter Chips
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _performSearch(_searchController.text);
                      },
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Start typing to search your entries'
                : 'No results found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: _buildResultCard(result),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultCard(dynamic result) {
    IconData icon;
    String title;
    String subtitle;
    Color iconColor;
    DateTime date;

    if (result is ReflectionEntry) {
      icon = Icons.edit_note;
      title = 'Reflection';
      subtitle =
          result.reflection.length > 100
              ? '${result.reflection.substring(0, 100)}...'
              : result.reflection;
      iconColor = Colors.blue;
      date = result.date;
    } else if (result is MoodEntry) {
      icon = Icons.mood;
      title = 'Mood: ${result.mood.name}';
      subtitle = result.notes ?? 'No note added';
      iconColor = _getMoodColor(result.mood);
      date = result.date;
    } else {
      icon = Icons.flag;
      title = (result as dynamic).title ?? 'Goal';
      subtitle = (result as dynamic).description ?? '';
      iconColor = Colors.green;
      date = (result as dynamic).createdAt ?? DateTime.now();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () {
          // Navigate to detail view based on result type
          // Implementation would depend on your navigation structure
        },
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.yellow;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.angry:
        return Colors.red;
      case MoodType.anxious:
        return Colors.orange;
      case MoodType.calm:
        return Colors.green;
      case MoodType.excited:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
