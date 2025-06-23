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
    with TickerProviderStateMixin, SafeStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _navigationAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _navigationSlideAnimation;
  late Animation<double> _navigationOpacityAnimation;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _navigationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _navigationSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navigationAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _navigationOpacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _navigationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _navigationAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Screen transition animation
      _animationController.forward().then((_) {
        safeSetState(() {
          _currentIndex = index;
        });
        _animationController.reverse();
      });

      // Navigation bar micro-animation
      _navigationAnimationController.reset();
      _navigationAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: IndexedStack(index: _currentIndex, children: _screens),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navigationAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _navigationSlideAnimation.value)),
            child: Opacity(
              opacity: _navigationOpacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, -8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onItemTapped,
                    animationDuration: const Duration(milliseconds: 300),
                    height: 75,
                    elevation: 0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.95),
                    destinations: [
                      NavigationDestination(
                        icon: _buildAnimatedIcon(Icons.home_outlined, 0),
                        selectedIcon: _buildAnimatedIcon(Icons.home, 0),
                        label: _tabTitles[0],
                      ),
                      NavigationDestination(
                        icon: _buildAnimatedIcon(
                          Icons.calendar_month_outlined,
                          1,
                        ),
                        selectedIcon: _buildAnimatedIcon(
                          Icons.calendar_month,
                          1,
                        ),
                        label: _tabTitles[1],
                      ),
                      NavigationDestination(
                        icon: _buildAnimatedIcon(Icons.mood_outlined, 2),
                        selectedIcon: _buildAnimatedIcon(Icons.mood, 2),
                        label: _tabTitles[2],
                      ),
                      NavigationDestination(
                        icon: _buildAnimatedIcon(Icons.analytics_outlined, 3),
                        selectedIcon: _buildAnimatedIcon(Icons.analytics, 3),
                        label: _tabTitles[3],
                      ),
                      NavigationDestination(
                        icon: _buildAnimatedIcon(Icons.search_outlined, 4),
                        selectedIcon: _buildAnimatedIcon(Icons.search, 4),
                        label: _tabTitles[4],
                      ),
                      NavigationDestination(
                        icon: _buildAnimatedIcon(Icons.settings_outlined, 5),
                        selectedIcon: _buildAnimatedIcon(Icons.settings, 5),
                        label: _tabTitles[5],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData iconData, int index) {
    final isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSelected ? 8 : 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        child: Icon(
          iconData,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 24,
        ),
      ),
    );
  }
}
