import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class AffirmationGardenScreen extends StatefulWidget {
  const AffirmationGardenScreen({super.key});

  @override
  State<AffirmationGardenScreen> createState() =>
      _AffirmationGardenScreenState();
}

class _AffirmationGardenScreenState extends State<AffirmationGardenScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _bloomController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _bloomAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _bloomController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _bloomAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bloomController, curve: Curves.elasticOut),
    );

    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _bloomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AffirmationGardenProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Affirmation Garden'),
          centerTitle: true,
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () => _showAddAffirmationDialog(context),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue.shade100,
                Colors.green.shade50,
                Colors.green.shade100,
              ],
            ),
          ),
          child: Consumer<AffirmationGardenProvider>(
            builder: (context, provider, child) {
              return CustomScrollView(
                slivers: [
                  // Garden Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _floatingAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatingAnimation.value),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.local_florist,
                                            size: 32,
                                            color: Colors.green.shade700,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Your Garden Stats',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildStatCard(
                                            'Planted',
                                            provider.plantedCount.toString(),
                                            Icons.eco,
                                            Colors.green,
                                          ),
                                          _buildStatCard(
                                            'Blooming',
                                            provider.bloomingCount.toString(),
                                            Icons.local_florist,
                                            Colors.pink,
                                          ),
                                          _buildStatCard(
                                            'Days Active',
                                            provider.activeDays.toString(),
                                            Icons.calendar_today,
                                            Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Daily Affirmation
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade300,
                                  Colors.pink.shade300,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.wb_sunny,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Today\'s Affirmation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.dailyAffirmation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    provider.generateNewDailyAffirmation();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('New Affirmation'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Garden Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index < provider.affirmations.length) {
                          final affirmation = provider.affirmations[index];
                          return _buildAffirmationPlant(
                            affirmation,
                            provider,
                            context,
                          );
                        } else {
                          return _buildEmptyPlot(context, provider);
                        }
                      }, childCount: max(provider.affirmations.length + 2, 8)),
                    ),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildActionChip(
                                'Water All Plants',
                                Icons.water_drop,
                                Colors.blue,
                                () => provider.waterAllPlants(),
                              ),
                              _buildActionChip(
                                'Random Affirmation',
                                Icons.shuffle,
                                Colors.purple,
                                () => _showRandomAffirmation(context, provider),
                              ),
                              _buildActionChip(
                                'Garden History',
                                Icons.history,
                                Colors.orange,
                                () => _showGardenHistory(context, provider),
                              ),
                              _buildActionChip(
                                'Export Garden',
                                Icons.download,
                                Colors.teal,
                                () => _exportGarden(context, provider),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddAffirmationDialog(context),
          backgroundColor: Colors.green.shade600,
          icon: const Icon(Icons.add),
          label: const Text('Plant Affirmation'),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmationPlant(
    AffirmationPlant plant,
    AffirmationGardenProvider provider,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _showPlantDetails(context, plant, provider),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Plant Icon with Growth Animation
              AnimatedBuilder(
                animation: _bloomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        plant.isBloomin
                            ? (0.8 + 0.4 * _bloomAnimation.value)
                            : 0.8,
                    child: Icon(
                      plant.getPlantIcon(),
                      size: 48,
                      color: plant.getPlantColor(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Growth Level
              LinearProgressIndicator(
                value: plant.growthLevel / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  plant.getPlantColor(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${plant.growthLevel.toInt()}% grown',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Affirmation Text
              Expanded(
                child: Text(
                  plant.affirmation,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed:
                        plant.canWater()
                            ? () {
                              provider.waterPlant(plant);
                              if (plant.isBloomin) {
                                _bloomController.forward().then((_) {
                                  _bloomController.reset();
                                });
                              }
                            }
                            : null,
                    icon: Icon(
                      Icons.water_drop,
                      color: plant.canWater() ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.tendPlant(plant),
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlot(
    BuildContext context,
    AffirmationGardenProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _showAddAffirmationDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.brown.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.brown.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              'Empty Plot',
              style: TextStyle(
                color: Colors.brown.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to plant',
              style: TextStyle(color: Colors.brown.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      onPressed: onTap,
    );
  }

  void _showAddAffirmationDialog(BuildContext context) {
    final provider = Provider.of<AffirmationGardenProvider>(
      context,
      listen: false,
    );
    final controller = TextEditingController();
    String selectedCategory = 'Self-Love';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Plant New Affirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Your Affirmation',
                    hintText: 'I am worthy of love and happiness',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      provider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (value) => selectedCategory = value!,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    provider.plantAffirmation(
                      controller.text,
                      selectedCategory,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Plant'),
              ),
            ],
          ),
    );
  }

  void _showPlantDetails(
    BuildContext context,
    AffirmationPlant plant,
    AffirmationGardenProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(plant.getPlantIcon(), color: plant.getPlantColor()),
                const SizedBox(width: 8),
                const Text('Plant Details'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.affirmation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Category: ${plant.category}'),
                Text(
                  'Planted: ${plant.plantedDate.day}/${plant.plantedDate.month}/${plant.plantedDate.year}',
                ),
                Text('Growth: ${plant.growthLevel.toInt()}%'),
                Text('Times watered: ${plant.waterCount}'),
                Text('Times tended: ${plant.tendCount}'),
                if (plant.isBloomin)
                  const Text(
                    '🌸 Currently blooming!',
                    style: TextStyle(color: Colors.pink),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (plant.growthLevel >= 100)
                ElevatedButton(
                  onPressed: () {
                    provider.harvestPlant(plant);
                    Navigator.pop(context);
                  },
                  child: const Text('Harvest'),
                ),
            ],
          ),
    );
  }

  void _showRandomAffirmation(
    BuildContext context,
    AffirmationGardenProvider provider,
  ) {
    final randomAffirmation = provider.getRandomAffirmation();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text('Random Affirmation'),
              ],
            ),
            content: Text(
              randomAffirmation,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.plantAffirmation(randomAffirmation, 'Random');
                  Navigator.pop(context);
                },
                child: const Text('Plant This'),
              ),
            ],
          ),
    );
  }

  void _showGardenHistory(
    BuildContext context,
    AffirmationGardenProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Garden History'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: provider.gardenHistory.length,
                itemBuilder: (context, index) {
                  final entry = provider.gardenHistory[index];
                  return ListTile(
                    leading: Icon(
                      entry['type'] == 'plant'
                          ? Icons.eco
                          : entry['type'] == 'water'
                          ? Icons.water_drop
                          : entry['type'] == 'harvest'
                          ? Icons.star
                          : Icons.favorite,
                      color: Colors.green,
                    ),
                    title: Text(entry['action'] ?? ''),
                    subtitle: Text(entry['date'] ?? ''),
                  );
                },
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

  void _exportGarden(BuildContext context, AffirmationGardenProvider provider) {
    provider.exportGarden();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Garden exported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class AffirmationPlant {
  final String id;
  final String affirmation;
  final String category;
  final DateTime plantedDate;
  double growthLevel;
  int waterCount;
  int tendCount;
  DateTime lastWatered;

  AffirmationPlant({
    required this.id,
    required this.affirmation,
    required this.category,
    required this.plantedDate,
    this.growthLevel = 10.0,
    this.waterCount = 0,
    this.tendCount = 0,
    DateTime? lastWatered,
  }) : lastWatered =
           lastWatered ?? DateTime.now().subtract(const Duration(hours: 25));

  bool get isBloomin => growthLevel >= 75;
  bool get isFullyGrown => growthLevel >= 100;

  bool canWater() {
    final hoursSinceLastWater = DateTime.now().difference(lastWatered).inHours;
    return hoursSinceLastWater >= 24; // Can water once per day
  }

  IconData getPlantIcon() {
    if (growthLevel < 25) return Icons.grass;
    if (growthLevel < 50) return Icons.eco;
    if (growthLevel < 75) return Icons.local_florist;
    return Icons.emoji_nature;
  }

  Color getPlantColor() {
    if (growthLevel < 25) return Colors.lightGreen;
    if (growthLevel < 50) return Colors.green;
    if (growthLevel < 75) return Colors.green.shade700;
    return Colors.pink;
  }
}

class AffirmationGardenProvider extends ChangeNotifier {
  final List<AffirmationPlant> _affirmations = [];
  final List<Map<String, String>> _gardenHistory = [];
  String _dailyAffirmation = '';
  int _activeDays = 1;

  List<AffirmationPlant> get affirmations => _affirmations;
  List<Map<String, String>> get gardenHistory => _gardenHistory;
  String get dailyAffirmation => _dailyAffirmation;
  int get activeDays => _activeDays;

  int get plantedCount => _affirmations.length;
  int get bloomingCount => _affirmations.where((p) => p.isBloomin).length;

  final List<String> categories = [
    'Self-Love',
    'Confidence',
    'Success',
    'Health',
    'Relationships',
    'Abundance',
    'Peace',
    'Gratitude',
    'Motivation',
    'Random',
  ];

  final List<String> _defaultAffirmations = [
    'I am worthy of love and happiness',
    'I choose peace over worry',
    'I am confident in my abilities',
    'I attract positive energy',
    'I am grateful for this moment',
    'I trust in my journey',
    'I am exactly where I need to be',
    'I radiate love and compassion',
    'I embrace change and growth',
    'I am enough, just as I am',
  ];

  AffirmationGardenProvider() {
    _initializeGarden();
  }
  void _initializeGarden() {
    generateNewDailyAffirmation();
    _addHistoryEntry('start', 'Started your affirmation garden');
  }

  void generateNewDailyAffirmation() {
    _dailyAffirmation =
        _defaultAffirmations[Random().nextInt(_defaultAffirmations.length)];
    notifyListeners();
  }

  void plantAffirmation(String affirmation, String category) {
    final plant = AffirmationPlant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      affirmation: affirmation,
      category: category,
      plantedDate: DateTime.now(),
    );

    _affirmations.add(plant);
    _addHistoryEntry('plant', 'Planted: "$affirmation"');
    notifyListeners();
  }

  void waterPlant(AffirmationPlant plant) {
    if (!plant.canWater()) return;

    plant.lastWatered = DateTime.now();
    plant.waterCount++;
    plant.growthLevel = (plant.growthLevel + 15).clamp(0, 100);

    _addHistoryEntry(
      'water',
      'Watered: "${plant.affirmation.substring(0, 20)}..."',
    );
    notifyListeners();
  }

  void tendPlant(AffirmationPlant plant) {
    plant.tendCount++;
    plant.growthLevel = (plant.growthLevel + 5).clamp(0, 100);

    _addHistoryEntry(
      'tend',
      'Tended: "${plant.affirmation.substring(0, 20)}..."',
    );
    notifyListeners();
  }

  void waterAllPlants() {
    int wateredCount = 0;
    for (final plant in _affirmations) {
      if (plant.canWater()) {
        waterPlant(plant);
        wateredCount++;
      }
    }

    if (wateredCount > 0) {
      _addHistoryEntry('water', 'Watered $wateredCount plants');
    }
  }

  void harvestPlant(AffirmationPlant plant) {
    _addHistoryEntry(
      'harvest',
      'Harvested: "${plant.affirmation.substring(0, 20)}..."',
    );
    _affirmations.remove(plant);
    notifyListeners();
  }

  String getRandomAffirmation() {
    return _defaultAffirmations[Random().nextInt(_defaultAffirmations.length)];
  }

  void exportGarden() {
    // In a real app, this would export to a file
    _addHistoryEntry('export', 'Exported garden data');
    notifyListeners();
  }

  void _addHistoryEntry(String type, String action) {
    _gardenHistory.insert(0, {
      'type': type,
      'action': action,
      'date':
          '${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });

    // Keep only last 50 entries
    if (_gardenHistory.length > 50) {
      _gardenHistory.removeRange(50, _gardenHistory.length);
    }
  }
}
