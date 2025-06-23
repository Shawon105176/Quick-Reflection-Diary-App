import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/safe_provider_base.dart';

// Model class for anonymous reflections
class AnonymousReflection {
  final String id;
  final String content;
  final String category;
  final String authorName;
  final DateTime createdAt;
  final bool isAnonymous;
  int heartsCount;
  int commentsCount;
  bool isLiked;

  AnonymousReflection({
    required this.id,
    required this.content,
    required this.category,
    required this.authorName,
    required this.createdAt,
    this.isAnonymous = true,
    this.heartsCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  String getAvatarInitial() {
    return isAnonymous ? '?' : authorName.substring(0, 1).toUpperCase();
  }

  Color getAvatarColor() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[id.hashCode % colors.length];
  }

  Color getCategoryColor() {
    switch (category) {
      case 'Life Lessons':
        return Colors.blue;
      case 'Gratitude':
        return Colors.green;
      case 'Challenges':
        return Colors.orange;
      case 'Dreams & Goals':
        return Colors.purple;
      case 'Relationships':
        return Colors.pink;
      case 'Self-Discovery':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String getTimeAgo() {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Provider class for managing anonymous reflections
class AnonymousReflectionProvider extends SafeChangeNotifier {
  final List<AnonymousReflection> _allReflections = [];
  final List<AnonymousReflection> _userReflections = [];
  final List<AnonymousReflection> _likedReflections = [];
  String _selectedCategory = 'All';

  List<AnonymousReflection> get allReflections => _allReflections;
  List<AnonymousReflection> get userReflections => _userReflections;
  List<AnonymousReflection> get likedReflections => _likedReflections;
  String get selectedCategory => _selectedCategory;

  int get activeUsers => 42 + _userReflections.length;
  int get totalReflections => _allReflections.length;
  int get totalHearts =>
      _allReflections.fold(0, (sum, r) => sum + r.heartsCount);

  AnonymousReflectionProvider() {
    _initializeSampleData();
  }
  List<String> get categories => [
    'All',
    'Life Lessons',
    'Gratitude',
    'Challenges',
    'Dreams & Goals',
    'Relationships',
    'Self-Discovery',
  ];

  List<String> get shareCategories => [
    'Life Lessons',
    'Gratitude',
    'Challenges',
    'Dreams & Goals',
    'Relationships',
    'Self-Discovery',
  ];

  List<AnonymousReflection> get filteredReflections {
    if (_selectedCategory == 'All') {
      return _allReflections;
    }
    return _allReflections
        .where((r) => r.category == _selectedCategory)
        .toList();
  }

  void _initializeSampleData() {
    final sampleReflections = [
      AnonymousReflection(
        id: '1',
        content:
            'Today I realized that every sunset is a gentle reminder that endings can be beautiful too. Sometimes we need to let go of the day to welcome the night.',
        category: 'Life Lessons',
        authorName: 'Mindful Wanderer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        heartsCount: 12,
        commentsCount: 3,
      ),
      AnonymousReflection(
        id: '2',
        content:
            'Grateful for the small moments today - the warm cup of coffee in my hands, the smile from a stranger, and the way sunlight filtered through my window.',
        category: 'Gratitude',
        authorName: 'Hopeful Heart',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        heartsCount: 8,
        commentsCount: 1,
      ),
      AnonymousReflection(
        id: '3',
        content:
            'Facing my fears isn\'t about being fearless - it\'s about being afraid and choosing to move forward anyway. Today I took one small brave step.',
        category: 'Challenges',
        authorName: 'Brave Soul',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        heartsCount: 15,
        commentsCount: 5,
      ),
      AnonymousReflection(
        id: '4',
        content:
            'My dream feels so big and overwhelming sometimes. But I\'m learning that every great journey begins with a single step, and I\'m taking mine today.',
        category: 'Dreams & Goals',
        authorName: 'Dream Chaser',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        heartsCount: 20,
        commentsCount: 7,
      ),
    ];
    _allReflections.addAll(sampleReflections);
    notifyListeners();
  }

  void addReflection(String content, String category, bool isAnonymous) {
    final reflection = AnonymousReflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      category: category,
      authorName: isAnonymous ? _generateAnonymousName() : 'You',
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    _allReflections.insert(0, reflection);
    _userReflections.insert(0, reflection);
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void shareReflection(String content, String category, bool isAnonymous) {
    addReflection(content, category, isAnonymous);
  }

  void toggleLike(AnonymousReflection reflection) {
    final index = _allReflections.indexWhere((r) => r.id == reflection.id);
    if (index != -1) {
      if (_allReflections[index].isLiked) {
        _allReflections[index].heartsCount--;
        _allReflections[index].isLiked = false;
        _likedReflections.removeWhere((r) => r.id == reflection.id);
      } else {
        _allReflections[index].heartsCount++;
        _allReflections[index].isLiked = true;
        _likedReflections.add(_allReflections[index]);
      }
      notifyListeners();
    }
  }

  void deleteReflection(AnonymousReflection reflection) {
    _allReflections.removeWhere((r) => r.id == reflection.id);
    _userReflections.removeWhere((r) => r.id == reflection.id);
    _likedReflections.removeWhere((r) => r.id == reflection.id);
    notifyListeners();
  }

  String _generateAnonymousName() {
    final adjectives = [
      'Thoughtful',
      'Peaceful',
      'Mindful',
      'Gentle',
      'Wise',
      'Kind',
      'Hopeful',
      'Brave',
      'Calm',
      'Bright',
    ];

    final nouns = [
      'Soul',
      'Heart',
      'Spirit',
      'Mind',
      'Dreamer',
      'Wanderer',
      'Seeker',
      'Friend',
      'Thinker',
      'Explorer',
      'Guide',
      'Light',
      'Voice',
      'Journey',
    ];

    final random = Random();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];

    return '$adjective $noun';
  }
}

class AnonymousReflectionCommunityScreen extends StatefulWidget {
  const AnonymousReflectionCommunityScreen({super.key});

  @override
  State<AnonymousReflectionCommunityScreen> createState() =>
      _AnonymousReflectionCommunityScreenState();
}

class _AnonymousReflectionCommunityScreenState
    extends State<AnonymousReflectionCommunityScreen>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  late AnimationController _fadeController;
  late AnimationController _heartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = createSafeAnimationController(
      duration: const Duration(milliseconds: 800),
    );
    _heartController = createSafeAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnonymousReflectionProvider(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Anonymous Reflections'),
            centerTitle: true,
            backgroundColor: Colors.deepPurple.shade600,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.explore), text: 'Explore'),
                Tab(icon: Icon(Icons.add_circle), text: 'Share'),
                Tab(icon: Icon(Icons.favorite), text: 'Liked'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showCommunityGuidelines(context),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.purple.shade50,
                  Colors.pink.shade50,
                ],
              ),
            ),
            child: Consumer<AnonymousReflectionProvider>(
              builder: (context, provider, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    children: [
                      _buildExploreTab(provider),
                      _buildShareTab(provider),
                      _buildLikedTab(provider),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreTab(AnonymousReflectionProvider provider) {
    return CustomScrollView(
      slivers: [
        // Community Stats Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.groups, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Community Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCommunityStatCard(
                      'Active\nReflectors',
                      '${provider.activeUsers}',
                      Icons.person,
                    ),
                    _buildCommunityStatCard(
                      'Shared\nReflections',
                      '${provider.totalReflections}',
                      Icons.message,
                    ),
                    _buildCommunityStatCard(
                      'Hearts\nGiven',
                      '${provider.totalHearts}',
                      Icons.favorite,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Filter Options
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      final isSelected = provider.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            provider.setSelectedCategory(
                              selected ? category : 'All',
                            );
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.purple.shade100,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Reflections List
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final reflection = provider.filteredReflections[index];
            return _buildReflectionCard(reflection, provider);
          }, childCount: provider.filteredReflections.length),
        ),
      ],
    );
  }

  Widget _buildShareTab(AnonymousReflectionProvider provider) {
    final TextEditingController reflectionController = TextEditingController();
    String selectedCategory = 'Life Lessons';
    bool isAnonymous = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Share Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.cyan.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Share Your Reflection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your thoughts might inspire someone else\'s journey',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reflection Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Reflection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: reflectionController,
                        decoration: const InputDecoration(
                          hintText: 'Share what\'s on your mind or heart...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFF8F9FA),
                        ),
                        maxLines: 6,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),

                      // Category Selection
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFF8F9FA),
                        ),
                        items:
                            provider.shareCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (value) {
                          safeSetState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Anonymous Toggle
                      SwitchListTile(
                        title: const Text('Share Anonymously'),
                        subtitle: const Text('Your identity will be hidden'),
                        value: isAnonymous,
                        onChanged: (value) {
                          safeSetState(() {
                            isAnonymous = value;
                          });
                        },
                        activeColor: Colors.purple,
                      ),
                      const SizedBox(height: 16),

                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              reflectionController.text.trim().isEmpty
                                  ? null
                                  : () {
                                    provider.shareReflection(
                                      reflectionController.text.trim(),
                                      selectedCategory,
                                      isAnonymous,
                                    );
                                    reflectionController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Reflection shared with the community!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                          icon: const Icon(Icons.send),
                          label: const Text('Share Reflection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Your Recent Shares
              const Text(
                'Your Recent Shares',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...provider.userReflections.take(3).map((reflection) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(Icons.person, color: Colors.purple.shade600),
                    ),
                    title: Text(
                      reflection.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${reflection.category} • ${reflection.heartsCount} hearts',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        provider.deleteReflection(reflection);
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLikedTab(AnonymousReflectionProvider provider) {
    return provider.likedReflections.isEmpty
        ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No liked reflections yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the heart on reflections you connect with',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.likedReflections.length,
          itemBuilder: (context, index) {
            final reflection = provider.likedReflections[index];
            return _buildReflectionCard(reflection, provider);
          },
        );
  }

  Widget _buildCommunityStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReflectionCard(
    AnonymousReflection reflection,
    AnonymousReflectionProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: reflection.getAvatarColor(),
                  child: Text(
                    reflection.getAvatarInitial(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reflection.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${reflection.category} • ${reflection.getTimeAgo()}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reflection.getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: reflection.getCategoryColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    reflection.category,
                    style: TextStyle(
                      color: reflection.getCategoryColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              reflection.content,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                AnimatedBuilder(
                  animation: _heartAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: reflection.isLiked ? _heartAnimation.value : 1.0,
                      child: IconButton(
                        onPressed: () {
                          provider.toggleLike(reflection);
                          if (reflection.isLiked) {
                            _heartController.forward().then((_) {
                              _heartController.reverse();
                            });
                          }
                        },
                        icon: Icon(
                          reflection.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: reflection.isLiked ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  reflection.heartsCount.toString(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _showReflectionDetails(context, reflection),
                  icon: Icon(
                    Icons.comment_outlined,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  reflection.commentsCount.toString(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _shareReflection(context, reflection),
                  icon: Icon(Icons.share_outlined, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommunityGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('Community Guidelines'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🌟 Be Kind & Respectful',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Treat all community members with kindness and respect.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🤝 Stay Anonymous',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Personal information is not shared. Focus on thoughts and feelings.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '💝 Support Others',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Offer encouragement and empathy to fellow reflectors.'),
                  SizedBox(height: 8),
                  Text(
                    '🚫 No Harmful Content',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Avoid content that could harm or trigger others.'),
                  SizedBox(height: 8),
                  Text(
                    '🌱 Share Authentically',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Share genuine thoughts and experiences to inspire others.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showReflectionDetails(
    BuildContext context,
    AnonymousReflection reflection,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${reflection.authorName}\'s Reflection'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reflection.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category: ${reflection.category}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  Text(
                    'Shared: ${reflection.getTimeAgo()}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _shareReflection(BuildContext context, AnonymousReflection reflection) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection shared!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
