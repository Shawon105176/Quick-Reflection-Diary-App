import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late PageController _pageController;

  final List<Widget> _screens = [
    const ModernHomeScreen(),
    const CalendarScreen(),
    const EnhancedMoodTrackerScreen(),
    const AnalyticsScreen(),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  final List<IconData> _icons = [
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
    _pageController = PageController(initialPage: _currentIndex);

    // Animation for FAB-style selected icon
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Animate FAB-style icon
      _fabAnimationController.reset();
      _fabAnimationController.forward();

      // Animate to new page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      safeSetState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          safeSetState(() {
            _currentIndex = index;
          });
          _fabAnimationController.reset();
          _fabAnimationController.forward();
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 65,
        items:
            _icons.asMap().entries.map((entry) {
              int index = entry.key;
              IconData icon = entry.value;
              bool isSelected = _currentIndex == index;

              return AnimatedBuilder(
                animation: _fabScaleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? Colors.transparent : Colors.transparent,
                    ),
                    child: Transform.scale(
                      scale:
                          isSelected
                              ? (0.8 + (0.4 * _fabScaleAnimation.value))
                              : 0.8,
                      child: Icon(
                        icon,
                        size: isSelected ? 30 : 25,
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
        color: theme.colorScheme.surface,
        buttonBackgroundColor: theme.colorScheme.primary,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
