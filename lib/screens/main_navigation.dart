import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _iconAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _bounceAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
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
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.mood_rounded,
    Icons.analytics_rounded,
    Icons.search_rounded,
    Icons.settings_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Icon scaling animation
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Pulse animation for selected icon
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // Bounce animation for tap feedback
    _bounceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _bounceAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start initial animations
    _iconAnimationController.forward();
    _startPulseAnimation();
  }

  void _startPulseAnimation() {
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _pulseAnimationController.dispose();
    _bounceAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Premium haptic feedback
      HapticFeedback.mediumImpact();

      // Bounce animation for premium tap feedback
      _bounceAnimationController.forward().then((_) {
        _bounceAnimationController.reverse();
      });

      // Reset and restart icon scaling animation with stagger
      _iconAnimationController.reset();
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _iconAnimationController.forward();
      });

      // Smooth page transition with custom curve
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );

      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _iconAnimationController.reset();
              _iconAnimationController.forward();
              HapticFeedback.selectionClick();
            },
          ),
          // Gradient overlay at bottom for better visual separation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withOpacity(0.8),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          key: GlobalKey<CurvedNavigationBarState>(),
          index: _currentIndex,
          height: 70,
          items:
              _icons.asMap().entries.map((entry) {
                int index = entry.key;
                IconData icon = entry.value;
                bool isSelected = _currentIndex == index;
                return AnimatedBuilder(
                  animation: Listenable.merge([
                    _iconScaleAnimation,
                    _pulseAnimation,
                    _bounceAnimation,
                  ]),
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.4),
                                    blurRadius:
                                        12 *
                                        _pulseAnimation.value.clamp(0.0, 1.0),
                                    spreadRadius:
                                        3 *
                                        _pulseAnimation.value.clamp(0.0, 1.0),
                                  ),
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    blurRadius:
                                        20 *
                                        _pulseAnimation.value.clamp(0.0, 1.0),
                                    spreadRadius:
                                        5 *
                                        _pulseAnimation.value.clamp(0.0, 1.0),
                                  ),
                                ]
                                : null,
                      ),
                      child: Transform.scale(
                        scale:
                            isSelected
                                ? (_iconScaleAnimation.value.clamp(0.0, 2.0) *
                                    _bounceAnimation.value.clamp(0.0, 1.0))
                                : (0.8 *
                                    _bounceAnimation.value.clamp(0.0, 1.0)),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                isSelected
                                    ? RadialGradient(
                                      colors: [
                                        colorScheme.primary.withOpacity(0.15),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.4, 1.0],
                                    )
                                    : null,
                          ),
                          child: Icon(
                            icon,
                            size: isSelected ? 30 : 26,
                            color:
                                isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
          color: colorScheme.surface.withOpacity(0.95),
          buttonBackgroundColor: colorScheme.primary,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 500),
          onTap: _onItemTapped,
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
