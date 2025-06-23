import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class JournalCoverProvider extends ChangeNotifier {
  String? _selectedCover;
  String? _customCoverPath;

  String? get selectedCover => _selectedCover;
  String? get customCoverPath => _customCoverPath;

  final List<String> _premiumCovers = [
    'assets/covers/nature_1.jpg',
    'assets/covers/abstract_1.jpg',
    'assets/covers/minimalist_1.jpg',
    'assets/covers/space_1.jpg',
    'assets/covers/ocean_1.jpg',
    'assets/covers/forest_1.jpg',
    'assets/covers/sunset_1.jpg',
    'assets/covers/mountain_1.jpg',
  ];

  List<String> get premiumCovers => _premiumCovers;

  void selectCover(String coverPath) {
    _selectedCover = coverPath;
    _customCoverPath = null;
    notifyListeners();
  }

  Future<void> uploadCustomCover() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      _customCoverPath = image.path;
      _selectedCover = null;
      notifyListeners();
    }
  }

  void resetToDefault() {
    _selectedCover = null;
    _customCoverPath = null;
    notifyListeners();
  }

  Widget buildCoverBackground(Widget child) {
    if (_customCoverPath != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(_customCoverPath!)),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: child,
      );
    } else if (_selectedCover != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_selectedCover!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: child,
      );
    } else {
      return child;
    }
  }
}

class CoverSelectionScreen extends StatefulWidget {
  const CoverSelectionScreen({super.key});

  @override
  State<CoverSelectionScreen> createState() => _CoverSelectionScreenState();
}

class _CoverSelectionScreenState extends State<CoverSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JournalCoverProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Journal Cover'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                // Reset to default
                context.read<JournalCoverProvider>().resetToDefault();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Premium Covers Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Premium Covers',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Beautiful curated wallpapers for your journal',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

                // Premium Covers Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: Consumer<JournalCoverProvider>(
                    builder: (context, provider, child) {
                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final coverPath = provider.premiumCovers[index];
                          return _buildCoverTile(coverPath, isPremium: true);
                        }, childCount: provider.premiumCovers.length),
                      );
                    },
                  ),
                ),

                // Custom Upload Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Custom Cover',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your own photo as journal cover',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),

                        // Upload Button
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.05),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await context
                                    .read<JournalCoverProvider>()
                                    .uploadCustomCover();
                                if (mounted) Navigator.pop(context);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 48,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload Custom Cover',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to choose from gallery',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverTile(String coverPath, {bool isPremium = false}) {
    return Consumer<JournalCoverProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.selectedCover == coverPath;

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            provider.selectCover(coverPath);
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image (placeholder for now)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getGradientColors(coverPath),
                      ),
                    ),
                  ),

                  // Premium Badge
                  if (isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Selected Indicator
                  if (isSelected)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors(String coverPath) {
    // Generate different gradients based on cover path
    final gradients = [
      [Colors.blue.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.red.shade600],
      [Colors.green.shade400, Colors.teal.shade600],
      [Colors.purple.shade400, Colors.pink.shade600],
      [Colors.teal.shade400, Colors.blue.shade600],
      [Colors.indigo.shade400, Colors.purple.shade600],
      [Colors.amber.shade400, Colors.orange.shade600],
      [Colors.cyan.shade400, Colors.blue.shade600],
    ];

    final index = coverPath.hashCode % gradients.length;
    return gradients[index.abs()];
  }
}
