import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/safe_provider_base.dart';

class ReflectionTopic {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> prompts;
  final IconData icon;
  final Color color;

  ReflectionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prompts,
    required this.icon,
    required this.color,
  });
}

class ReflectionEntry {
  final String id;
  final String topicId;
  final String topicTitle;
  final String content;
  final DateTime createdAt;
  final String prompt;
  final List<String> tags;

  ReflectionEntry({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.content,
    required this.createdAt,
    required this.prompt,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'topicId': topicId,
    'topicTitle': topicTitle,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'prompt': prompt,
    'tags': tags,
  };

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) =>
      ReflectionEntry(
        id: json['id'],
        topicId: json['topicId'],
        topicTitle: json['topicTitle'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        prompt: json['prompt'],
        tags: List<String>.from(json['tags']),
      );
}

class ReflectionLibraryProvider extends ChangeNotifier {
  final List<ReflectionTopic> _topics = _generateTopics();
  final List<ReflectionEntry> _entries = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ReflectionTopic> get topics {
    var filtered = _topics;

    if (_selectedCategory != 'All') {
      filtered =
          filtered
              .where((topic) => topic.category == _selectedCategory)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (topic) =>
                    topic.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    topic.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  List<ReflectionEntry> get entries => _entries;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories => [
    'All',
    'Self-Discovery',
    'Relationships',
    'Growth',
    'Gratitude',
    'Goals',
    'Mindfulness',
    'Creativity',
    'Career',
    'Health',
  ];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addEntry(ReflectionEntry entry) {
    _entries.add(entry);
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  List<ReflectionEntry> getEntriesForTopic(String topicId) {
    return _entries.where((entry) => entry.topicId == topicId).toList();
  }

  ReflectionTopic? getTopicById(String id) {
    try {
      return _topics.firstWhere((topic) => topic.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ReflectionTopic> _generateTopics() {
    return [
      // Self-Discovery
      ReflectionTopic(
        id: '1',
        title: 'Values & Beliefs',
        description: 'Explore what truly matters to you and why',
        category: 'Self-Discovery',
        icon: Icons.psychology,
        color: Colors.purple,
        prompts: [
          'What are the three most important values that guide your decisions?',
          'Describe a time when you had to choose between two important values. How did you decide?',
          'What belief about yourself would you like to change, and why?',
          'How have your values evolved over the past five years?',
        ],
      ),
      ReflectionTopic(
        id: '2',
        title: 'Childhood Memories',
        description: 'Reflect on formative experiences from your past',
        category: 'Self-Discovery',
        icon: Icons.child_care,
        color: Colors.orange,
        prompts: [
          'What is your earliest memory, and how does it make you feel?',
          'Describe a childhood moment that shaped who you are today.',
          'What did you love most about being a child?',
          'How would you comfort your younger self during a difficult time?',
        ],
      ),

      // Relationships
      ReflectionTopic(
        id: '3',
        title: 'Love & Connection',
        description: 'Explore your relationships and emotional bonds',
        category: 'Relationships',
        icon: Icons.favorite,
        color: Colors.red,
        prompts: [
          'What does love mean to you?',
          'Describe someone who has had a profound impact on your life.',
          'How do you show love to others?',
          'What have your relationships taught you about yourself?',
        ],
      ),
      ReflectionTopic(
        id: '4',
        title: 'Friendship',
        description: 'Reflect on the friendships that matter most',
        category: 'Relationships',
        icon: Icons.group,
        color: Colors.green,
        prompts: [
          'What qualities do you value most in a friend?',
          'Describe your oldest friendship. What has kept it strong?',
          'How have you grown through your friendships?',
          'What kind of friend are you to others?',
        ],
      ),

      // Growth
      ReflectionTopic(
        id: '5',
        title: 'Overcoming Challenges',
        description: 'Reflect on how difficulties have made you stronger',
        category: 'Growth',
        icon: Icons.trending_up,
        color: Colors.blue,
        prompts: [
          'Describe a time when you overcame a significant challenge.',
          'What strength did you discover in yourself during a difficult period?',
          'How do you typically handle stress and pressure?',
          'What advice would you give someone facing a similar challenge to one you\'ve overcome?',
        ],
      ),
      ReflectionTopic(
        id: '6',
        title: 'Learning & Growth',
        description: 'Explore your journey of personal development',
        category: 'Growth',
        icon: Icons.school,
        color: Colors.indigo,
        prompts: [
          'What is the most important lesson you\'ve learned this year?',
          'Describe a skill you\'ve developed that you\'re proud of.',
          'How do you like to learn new things?',
          'What area of your life would you most like to improve?',
        ],
      ),

      // Gratitude
      ReflectionTopic(
        id: '7',
        title: 'Daily Blessings',
        description: 'Appreciate the good things in your life',
        category: 'Gratitude',
        icon: Icons.sunny,
        color: Colors.amber,
        prompts: [
          'What are three things you\'re grateful for today?',
          'Describe a simple pleasure that brings you joy.',
          'Who in your life are you most thankful for, and why?',
          'What aspect of your health are you most grateful for?',
        ],
      ),
      ReflectionTopic(
        id: '8',
        title: 'Unexpected Gifts',
        description: 'Reflect on surprising sources of gratitude',
        category: 'Gratitude',
        icon: Icons.card_giftcard,
        color: Colors.pink,
        prompts: [
          'Describe something difficult that ultimately became a gift.',
          'What unexpected opportunity are you grateful for?',
          'How has a stranger\'s kindness impacted your day?',
          'What challenge taught you something valuable?',
        ],
      ),

      // Goals
      ReflectionTopic(
        id: '9',
        title: 'Dreams & Aspirations',
        description: 'Explore your hopes for the future',
        category: 'Goals',
        icon: Icons.star,
        color: Colors.deepPurple,
        prompts: [
          'What is your biggest dream, and what steps are you taking toward it?',
          'How do you want to be remembered?',
          'What would you do if you knew you couldn\'t fail?',
          'Describe your ideal life five years from now.',
        ],
      ),
      ReflectionTopic(
        id: '10',
        title: 'Progress & Achievements',
        description: 'Celebrate your accomplishments and growth',
        category: 'Goals',
        icon: Icons.emoji_events,
        color: Colors.cyan,
        prompts: [
          'What achievement are you most proud of?',
          'How have you changed since last year?',
          'What goal are you currently working toward?',
          'Describe a time when persistence paid off for you.',
        ],
      ),

      // Mindfulness
      ReflectionTopic(
        id: '11',
        title: 'Present Moment',
        description: 'Connect with your current experience',
        category: 'Mindfulness',
        icon: Icons.self_improvement,
        color: Colors.teal,
        prompts: [
          'How are you feeling right now, in this exact moment?',
          'What do you notice about your surroundings today?',
          'Describe the sensations in your body as you sit here.',
          'What thoughts keep returning to your mind lately?',
        ],
      ),
      ReflectionTopic(
        id: '12',
        title: 'Inner Peace',
        description: 'Explore what brings you calm and clarity',
        category: 'Mindfulness',
        icon: Icons.spa,
        color: Colors.lightGreen,
        prompts: [
          'What activities help you feel most peaceful?',
          'Describe a place where you feel completely at ease.',
          'How do you handle overwhelming emotions?',
          'What does inner peace mean to you?',
        ],
      ),

      // Creativity
      ReflectionTopic(
        id: '13',
        title: 'Creative Expression',
        description: 'Explore your artistic and creative side',
        category: 'Creativity',
        icon: Icons.palette,
        color: Colors.deepOrange,
        prompts: [
          'How do you express your creativity?',
          'Describe something beautiful you created or contributed to.',
          'What inspires your imagination?',
          'How does creativity play a role in your daily life?',
        ],
      ),
      ReflectionTopic(
        id: '14',
        title: 'Innovation & Ideas',
        description: 'Reflect on your problem-solving and innovation',
        category: 'Creativity',
        icon: Icons.lightbulb,
        color: Colors.yellow,
        prompts: [
          'Describe a creative solution you found to a problem.',
          'What new idea has excited you recently?',
          'How do you approach brainstorming and generating ideas?',
          'What would you create if resources were unlimited?',
        ],
      ),

      // Career
      ReflectionTopic(
        id: '15',
        title: 'Purpose & Passion',
        description: 'Explore your professional calling and meaning',
        category: 'Career',
        icon: Icons.work,
        color: Colors.brown,
        prompts: [
          'What aspects of your work bring you the most satisfaction?',
          'How does your career align with your personal values?',
          'What would your ideal work environment look like?',
          'Describe a moment when you felt truly engaged in your work.',
        ],
      ),

      // Health
      ReflectionTopic(
        id: '16',
        title: 'Mind-Body Connection',
        description: 'Reflect on your physical and mental well-being',
        category: 'Health',
        icon: Icons.favorite_border,
        color: Colors.red.shade300,
        prompts: [
          'How does your physical health affect your mood?',
          'What healthy habits have made the biggest difference in your life?',
          'Describe how you feel when you take good care of yourself.',
          'What does self-care mean to you?',
        ],
      ),
    ];
  }
}

class ReflectionLibraryScreen extends StatefulWidget {
  const ReflectionLibraryScreen({super.key});

  @override
  State<ReflectionLibraryScreen> createState() =>
      _ReflectionLibraryScreenState();
}

class _ReflectionLibraryScreenState extends State<ReflectionLibraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReflectionLibraryProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reflection Library'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showMyReflections(context),
              icon: const Icon(Icons.history),
              tooltip: 'My Reflections',
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: Consumer<ReflectionLibraryProvider>(
                  builder: (context, provider, child) {
                    return _buildTopicGrid(context, provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Consumer<ReflectionLibraryProvider>(
            builder: (context, provider, child) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search reflection topics...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      provider.searchQuery.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: provider.setSearchQuery,
              );
            },
          ),
          const SizedBox(height: 12),

          // Category filter
          Consumer<ReflectionLibraryProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      provider.categories.map((category) {
                        final isSelected =
                            provider.selectedCategory == category;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) => provider.setCategory(category),
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid(
    BuildContext context,
    ReflectionLibraryProvider provider,
  ) {
    final topics = provider.topics;

    if (topics.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return _buildTopicCard(context, topic, provider);
      },
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    ReflectionTopic topic,
    ReflectionLibraryProvider provider,
  ) {
    final theme = Theme.of(context);
    final entriesCount = provider.getEntriesForTopic(topic.id).length;

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openReflectionTopic(context, topic),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                topic.color.withOpacity(0.1),
                topic.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: topic.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(topic.icon, color: topic.color, size: 24),
                  ),
                  const Spacer(),
                  if (entriesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$entriesCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                topic.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  topic.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topic.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Topics Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _openReflectionTopic(BuildContext context, ReflectionTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionTopicScreen(topic: topic),
      ),
    );
  }

  void _showMyReflections(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyReflectionsScreen()),
    );
  }
}

class ReflectionTopicScreen extends StatefulWidget {
  final ReflectionTopic topic;

  const ReflectionTopicScreen({super.key, required this.topic});

  @override
  State<ReflectionTopicScreen> createState() => _ReflectionTopicScreenState();
}

class _ReflectionTopicScreenState extends State<ReflectionTopicScreen>
    with SafeStateMixin {
  String _selectedPrompt = '';
  final TextEditingController _reflectionController = TextEditingController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _selectedPrompt =
        widget.topic.prompts[_random.nextInt(widget.topic.prompts.length)];
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<ReflectionLibraryProvider>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topic.title),
          elevation: 0,
          backgroundColor: widget.topic.color.withOpacity(0.1),
          actions: [
            IconButton(
              onPressed: _getNewPrompt,
              icon: const Icon(Icons.refresh),
              tooltip: 'New Prompt',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [widget.topic.color.withOpacity(0.1), Colors.transparent],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopicHeader(context),
                const SizedBox(height: 24),
                _buildPromptCard(context),
                const SizedBox(height: 24),
                _buildReflectionEditor(context),
                const SizedBox(height: 24),
                _buildPreviousReflections(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.topic.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.topic.icon,
                color: widget.topic.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.topic.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.topic.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              widget.topic.color.withOpacity(0.1),
              widget.topic.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: widget.topic.color),
                const SizedBox(width: 8),
                Text(
                  'Reflection Prompt',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.topic.color,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _getNewPrompt,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedPrompt,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionEditor(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Reflection',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reflectionController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText:
                    'Take your time to reflect deeply...\n\nThere are no right or wrong answers. Let your thoughts flow naturally.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _reflectionController.clear();
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _canSave() ? _saveReflection : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Reflection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousReflections(BuildContext context) {
    return Consumer<ReflectionLibraryProvider>(
      builder: (context, provider, child) {
        final entries = provider.getEntriesForTopic(widget.topic.id);

        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous Reflections (${entries.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...entries.take(3).map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(entry.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.content,
                          style: theme.textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (entries.length > 3)
                  TextButton(
                    onPressed: () => _showAllReflections(context, entries),
                    child: Text('View all ${entries.length} reflections'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canSave() {
    return _reflectionController.text.trim().isNotEmpty;
  }

  void _saveReflection() {
    final entry = ReflectionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topicId: widget.topic.id,
      topicTitle: widget.topic.title,
      content: _reflectionController.text.trim(),
      createdAt: DateTime.now(),
      prompt: _selectedPrompt,
      tags: [widget.topic.category],
    );

    context.read<ReflectionLibraryProvider>().addEntry(entry);
    _reflectionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _getNewPrompt() {
    safeSetState(() {
      _selectedPrompt =
          widget.topic.prompts[_random.nextInt(widget.topic.prompts.length)];
    });
  }

  void _showAllReflections(
    BuildContext context,
    List<ReflectionEntry> entries,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                TopicReflectionsScreen(topic: widget.topic, entries: entries),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class MyReflectionsScreen extends StatelessWidget {
  const MyReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reflections'), elevation: 0),
      body: Consumer<ReflectionLibraryProvider>(
        builder: (context, provider, child) {
          final entries = provider.entries;

          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildReflectionCard(context, entry, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Reflections Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your reflection journey by\nexploring topics in the library',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Explore Topics'),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(
    BuildContext context,
    ReflectionEntry entry,
    ReflectionLibraryProvider provider,
  ) {
    final theme = Theme.of(context);
    final topic = provider.getTopicById(entry.topicId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReflectionDetails(context, entry, topic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (topic != null) ...[
                    Icon(topic.icon, color: topic.color, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      entry.topicTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(entry.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.prompt,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReflectionDetails(
    BuildContext context,
    ReflectionEntry entry,
    ReflectionTopic? topic,
  ) {
    showDialog(
      context: context,
      builder: (context) => ReflectionDetailsDialog(entry: entry, topic: topic),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class ReflectionDetailsDialog extends StatelessWidget {
  final ReflectionEntry entry;
  final ReflectionTopic? topic;

  const ReflectionDetailsDialog({super.key, required this.entry, this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    topic?.color.withOpacity(0.1) ??
                    theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (topic != null) ...[
                    Icon(topic!.icon, color: topic!.color),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.topicTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(entry.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prompt',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                          0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.prompt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Reflection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.content,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Implement delete functionality
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class TopicReflectionsScreen extends StatelessWidget {
  final ReflectionTopic topic;
  final List<ReflectionEntry> entries;

  const TopicReflectionsScreen({
    super.key,
    required this.topic,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${topic.title} Reflections'), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildReflectionCard(context, entry);
        },
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, ReflectionEntry entry) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReflectionDetails(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(entry.createdAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.prompt,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReflectionDetails(BuildContext context, ReflectionEntry entry) {
    showDialog(
      context: context,
      builder: (context) => ReflectionDetailsDialog(entry: entry, topic: topic),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
