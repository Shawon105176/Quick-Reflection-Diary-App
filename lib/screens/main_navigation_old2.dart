import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/safe_provider_base.dart';
import 'modern_home_screen.dart';
import 'calendar_screen.dart';
import 'enhanced_mood_tracker_screen.dart';
import 'analytics_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  int _currentIndex = 0;
  late Map<int, AnimationController> _iconControllers;
  late AnimationController _navigationBarController;
  late Animation<double> _navigationBarAnimation;

  final List<Widget> _screens = [
    const ModernHomeScreen(),
    const CalendarScreen(),
    const EnhancedMoodTrackerScreen(),
    const AnalyticsScreen(),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  final List<String> _tabTitles = [
    'Home',
    'Calendar',
    'Mood',
    'Analytics',
    'Search',
    'Settings',
  ];

  final List<IconData> _unselectedIcons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.mood_outlined,
    Icons.analytics_outlined,
    Icons.search_outlined,
    Icons.settings_outlined,
  ];

  final List<IconData> _selectedIcons = [
    Icons.home,
    Icons.calendar_month,
    Icons.mood,
    Icons.analytics,
    Icons.search,
    Icons.settings,
  ];
  @override
  void initState() {
    super.initState();

    // Navigation bar entrance animation controller
    _navigationBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    ); // Navigation bar entrance animation
    _navigationBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navigationBarController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
      // Ensure animation values stay within bounds
      if (mounted) {
        safeSetState(() {});
      }
    });

    // Initialize individual icon controllers for each tab
    _iconControllers = {};
    for (int i = 0; i < _screens.length; i++) {
      _iconControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
    }

    // Start with home selected and begin entrance animation
    _iconControllers[0]?.forward();
    _navigationBarController.forward();
  }

  @override
  void dispose() {
    for (var controller in _iconControllers.values) {
      controller.dispose();
    }
    _navigationBarController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Animate out the previous icon (if exists)
      if (_iconControllers.containsKey(_currentIndex)) {
        _iconControllers[_currentIndex]?.reverse();
      }

      // Animate in the new icon (if exists)
      if (_iconControllers.containsKey(index)) {
        _iconControllers[index]?.forward();
      }

      // Quick navigation bar pulse effect - with proper animation handling
      if (_navigationBarController.isCompleted &&
          !_navigationBarController.isAnimating) {
        _navigationBarController.animateTo(0.9).then((_) {
          _navigationBarController.animateTo(1.0);
        });
      }

      safeSetState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navigationBarAnimation,
        builder: (context, child) {
          // Ensure opacity is clamped between 0.0 and 1.0
          final clampedOpacity = _navigationBarAnimation.value.clamp(0.0, 1.0);
          final clampedTranslation = (_navigationBarAnimation.value).clamp(
            0.0,
            1.0,
          );

          return Transform.translate(
            offset: Offset(0, 10 * (1 - clampedTranslation)),
            child: Opacity(
              opacity: clampedOpacity,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onItemTapped,
                    animationDuration: const Duration(milliseconds: 400),
                    height: 70,
                    elevation: 0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.98),
                    indicatorColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    destinations: List.generate(_screens.length, (index) {
                      return NavigationDestination(
                        icon: _buildAnimatedIcon(index, false),
                        selectedIcon: _buildAnimatedIcon(index, true),
                        label: _tabTitles[index],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon(int index, bool isSelected) {
    final currentlySelected = _currentIndex == index;
    final iconData =
        isSelected && currentlySelected
            ? _selectedIcons[index]
            : _unselectedIcons[index];

    // Safety check for icon controller
    final controller = _iconControllers[index];
    if (controller == null) {
      return Icon(
        iconData,
        size: 24,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Clamp animation value to ensure it's within valid range
        final animationValue = controller.value.clamp(0.0, 1.0);

        return Container(
          padding: EdgeInsets.all(currentlySelected ? 8 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                currentlySelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(
                      (0.1 + (0.1 * animationValue)).clamp(0.0, 1.0),
                    )
                    : Colors.transparent,
          ),
          child: Transform.scale(
            scale: currentlySelected ? (1.0 + (0.2 * animationValue)) : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                iconData,
                size: 24,
                color:
                    currentlySelected
                        ? Color.lerp(
                          Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          Theme.of(context).colorScheme.primary,
                          animationValue,
                        )
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
