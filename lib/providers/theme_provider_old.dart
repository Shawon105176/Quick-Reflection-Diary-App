import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/app_settings.dart';

enum AppTheme {
  mindfulPurple,
  oceanBlue,
  forestGreen,
  sunsetOrange,
  roseGold,
  charcoalDark,
  cosmicTeal,
  vibrantCoral,
  elegantGold,
  dreamyLavender,
}

class ThemeProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  AppTheme _currentTheme = AppTheme.mindfulPurple;
  bool _isAnimatingTheme = false;
  Duration _animationDuration = const Duration(milliseconds: 300);

  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  AppTheme get currentTheme => _currentTheme;
  bool get isAnimatingTheme => _isAnimatingTheme;
  Duration get animationDuration => _animationDuration;

  // Premium theme features
  bool get hasGradients => [
    AppTheme.cosmicTeal,
    AppTheme.vibrantCoral,
    AppTheme.elegantGold,
    AppTheme.dreamyLavender,
  ].contains(_currentTheme);

  List<AppTheme> get premiumThemes => [
    AppTheme.cosmicTeal,
    AppTheme.vibrantCoral,
    AppTheme.elegantGold,
    AppTheme.dreamyLavender,
  ];

  List<AppTheme> get standardThemes => [
    AppTheme.mindfulPurple,
    AppTheme.oceanBlue,
    AppTheme.forestGreen,
    AppTheme.sunsetOrange,
    AppTheme.roseGold,
    AppTheme.charcoalDark,
  ];

  ThemeProvider() {
    _loadSettings();
  }
  void _loadSettings() {
    _settings = StorageService.getSettings();
    // Load theme preference from settings
    final themeIndex = AppTheme.values.indexWhere(
      (theme) => theme.name == _settings.selectedTheme,
    );
    _currentTheme = AppTheme.values[themeIndex >= 0 ? themeIndex : 0];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;

    _isAnimatingTheme = true;
    notifyListeners();

    // Add a small delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 100));

    _currentTheme = theme;
    _settings = _settings.copyWith(selectedTheme: theme.name);
    await StorageService.saveSettings(_settings);

    // Complete animation
    await Future.delayed(const Duration(milliseconds: 200));
    _isAnimatingTheme = false;
    notifyListeners();
  }

  Future<void> setThemeWithAnimation(
    AppTheme theme, {
    Duration? duration,
  }) async {
    if (_currentTheme == theme) return;

    final animDuration = duration ?? _animationDuration;

    _isAnimatingTheme = true;
    notifyListeners();

    await Future.delayed(animDuration);

    _currentTheme = theme;
    _settings = _settings.copyWith(selectedTheme: theme.name);
    await StorageService.saveSettings(_settings);

    _isAnimatingTheme = false;
    notifyListeners();
  }

  // Get theme icon based on theme type
  IconData get themeIcon {
    switch (_currentTheme) {
      case AppTheme.mindfulPurple:
        return Icons.psychology;
      case AppTheme.oceanBlue:
        return Icons.waves;
      case AppTheme.forestGreen:
        return Icons.forest;
      case AppTheme.sunsetOrange:
        return Icons.wb_sunny;
      case AppTheme.roseGold:
        return Icons.favorite;
      case AppTheme.charcoalDark:
        return Icons.business;
      case AppTheme.cosmicTeal:
        return Icons.rocket_launch;
      case AppTheme.vibrantCoral:
        return Icons.local_florist;
      case AppTheme.elegantGold:
        return Icons.diamond;
      case AppTheme.dreamyLavender:
        return Icons.bedtime;
    }
  }

  // Enhanced gradient decoration for premium themes
  Decoration get gradientDecoration {
    if (hasGradients) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      );
    }
    return BoxDecoration(color: primaryColor);
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Color get primaryColor {
    switch (_currentTheme) {
      case AppTheme.mindfulPurple:
        return const Color(0xFF6B73FF);
      case AppTheme.oceanBlue:
        return const Color(0xFF2196F3);
      case AppTheme.forestGreen:
        return const Color(0xFF4CAF50);
      case AppTheme.sunsetOrange:
        return const Color(0xFFFF6B35);
      case AppTheme.roseGold:
        return const Color(0xFFE91E63);
      case AppTheme.charcoalDark:
        return const Color(0xFF37474F);
      case AppTheme.cosmicTeal:
        return const Color(0xFF00BCD4);
      case AppTheme.vibrantCoral:
        return const Color(0xFFFF5722);
      case AppTheme.elegantGold:
        return const Color(0xFFFFB300);
      case AppTheme.dreamyLavender:
        return const Color(0xFF9C27B0);
    }
  }

  Color get accentColor {
    switch (_currentTheme) {
      case AppTheme.mindfulPurple:
        return const Color(0xFF9C27B0);
      case AppTheme.oceanBlue:
        return const Color(0xFF03DAC6);
      case AppTheme.forestGreen:
        return const Color(0xFF8BC34A);
      case AppTheme.sunsetOrange:
        return const Color(0xFFFFC107);
      case AppTheme.roseGold:
        return const Color(0xFFFFD700);
      case AppTheme.charcoalDark:
        return const Color(0xFF607D8B);
      case AppTheme.cosmicTeal:
        return const Color(0xFF26C6DA);
      case AppTheme.vibrantCoral:
        return const Color(0xFFFF7043);
      case AppTheme.elegantGold:
        return const Color(0xFFFFC107);
      case AppTheme.dreamyLavender:
        return const Color(0xFFBA68C8);
    }
  }

  // Premium gradient colors for enhanced themes
  List<Color> get gradientColors {
    switch (_currentTheme) {
      case AppTheme.cosmicTeal:
        return [
          const Color(0xFF00BCD4),
          const Color(0xFF26C6DA),
          const Color(0xFF4DD0E1),
        ];
      case AppTheme.vibrantCoral:
        return [
          const Color(0xFFFF5722),
          const Color(0xFFFF7043),
          const Color(0xFFFF8A65),
        ];
      case AppTheme.elegantGold:
        return [
          const Color(0xFFFFB300),
          const Color(0xFFFFC107),
          const Color(0xFFFFCA28),
        ];
      case AppTheme.dreamyLavender:
        return [
          const Color(0xFF9C27B0),
          const Color(0xFFBA68C8),
          const Color(0xFFCE93D8),
        ];
      default:
        return [primaryColor, accentColor];
    }
  }

  String get themeName {
    switch (_currentTheme) {
      case AppTheme.mindfulPurple:
        return 'Mindful Purple';
      case AppTheme.oceanBlue:
        return 'Ocean Blue';
      case AppTheme.forestGreen:
        return 'Forest Green';
      case AppTheme.sunsetOrange:
        return 'Sunset Orange';
      case AppTheme.roseGold:
        return 'Rose Gold';
      case AppTheme.charcoalDark:
        return 'Charcoal Dark';
      case AppTheme.cosmicTeal:
        return 'Cosmic Teal ✨';
      case AppTheme.vibrantCoral:
        return 'Vibrant Coral 🌺';
      case AppTheme.elegantGold:
        return 'Elegant Gold 👑';
      case AppTheme.dreamyLavender:
        return 'Dreamy Lavender 🌸';
    }
  }

  String get themeDescription {
    switch (_currentTheme) {
      case AppTheme.mindfulPurple:
        return 'Calming and focused';
      case AppTheme.oceanBlue:
        return 'Fresh and tranquil';
      case AppTheme.forestGreen:
        return 'Natural and grounding';
      case AppTheme.sunsetOrange:
        return 'Warm and energizing';
      case AppTheme.roseGold:
        return 'Elegant and romantic';
      case AppTheme.charcoalDark:
        return 'Professional and sleek';
      case AppTheme.cosmicTeal:
        return 'Futuristic with cosmic gradients';
      case AppTheme.vibrantCoral:
        return 'Bold with living coral vibes';
      case AppTheme.elegantGold:
        return 'Luxurious with golden accents';
      case AppTheme.dreamyLavender:
        return 'Soft with dreamy purple tones';
    }
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: hasGradients ? 8 : 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shadowColor: hasGradients ? primaryColor.withOpacity(0.3) : null,
      shape:
          hasGradients
              ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              )
              : null,
    ),
    cardTheme: CardTheme(
      elevation: hasGradients ? 8 : 3,
      shadowColor: Colors.black.withOpacity(hasGradients ? 0.2 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(hasGradients ? 20 : 16),
      ),
      color: Colors.white,
      surfaceTintColor: hasGradients ? primaryColor.withOpacity(0.05) : null,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: hasGradients ? 6 : 2,
        shadowColor: hasGradients ? primaryColor.withOpacity(0.4) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(hasGradients ? 16 : 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: hasGradients ? 32 : 24,
          vertical: hasGradients ? 16 : 12,
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: hasGradients ? 17 : 16,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape:
          hasGradients
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              : const CircleBorder(),
      elevation: hasGradients ? 8 : 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:
          hasGradients ? Colors.white.withOpacity(0.95) : Colors.white,
      indicatorColor: primaryColor.withOpacity(hasGradients ? 0.3 : 0.2),
      elevation: hasGradients ? 12 : 0,
      shadowColor: hasGradients ? Colors.black.withOpacity(0.1) : null,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:
          hasGradients ? primaryColor.withOpacity(0.08) : Colors.grey[100],
      selectedColor: primaryColor.withOpacity(hasGradients ? 0.25 : 0.2),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: hasGradients ? FontWeight.w500 : FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: hasGradients ? 16 : 12,
        vertical: hasGradients ? 10 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(hasGradients ? 25 : 20),
      ),
      elevation: hasGradients ? 2 : 0,
    ),
    dividerTheme: DividerThemeData(
      color: hasGradients ? primaryColor.withOpacity(0.1) : Colors.grey[300],
      thickness: hasGradients ? 0.8 : 0.5,
    ),
    listTileTheme: ListTileThemeData(
      shape:
          hasGradients
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : null,
      tileColor: hasGradients ? primaryColor.withOpacity(0.03) : null,
    ),
  );
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: hasGradients ? 8 : 0,
      backgroundColor:
          hasGradients ? const Color(0xFF0D1117) : const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shadowColor: hasGradients ? primaryColor.withOpacity(0.2) : null,
      shape:
          hasGradients
              ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              )
              : null,
    ),
    scaffoldBackgroundColor:
        hasGradients ? const Color(0xFF0D1117) : const Color(0xFF121212),
    cardTheme: CardTheme(
      elevation: hasGradients ? 12 : 3,
      shadowColor: Colors.black.withOpacity(hasGradients ? 0.4 : 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(hasGradients ? 20 : 16),
      ),
      color: hasGradients ? const Color(0xFF161B22) : const Color(0xFF1E1E1E),
      surfaceTintColor: hasGradients ? primaryColor.withOpacity(0.1) : null,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: hasGradients ? 8 : 2,
        shadowColor: hasGradients ? primaryColor.withOpacity(0.5) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(hasGradients ? 16 : 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: hasGradients ? 32 : 24,
          vertical: hasGradients ? 16 : 12,
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: hasGradients ? 17 : 16,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape:
          hasGradients
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              : const CircleBorder(),
      elevation: hasGradients ? 12 : 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:
          hasGradients
              ? const Color(0xFF161B22).withOpacity(0.95)
              : const Color(0xFF1E1E1E),
      indicatorColor: primaryColor.withOpacity(hasGradients ? 0.4 : 0.3),
      elevation: hasGradients ? 16 : 0,
      shadowColor: hasGradients ? Colors.black.withOpacity(0.3) : null,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[400],
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:
          hasGradients ? primaryColor.withOpacity(0.15) : Colors.grey[800],
      selectedColor: primaryColor.withOpacity(hasGradients ? 0.4 : 0.3),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white,
        fontWeight: hasGradients ? FontWeight.w500 : FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: hasGradients ? 16 : 12,
        vertical: hasGradients ? 10 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(hasGradients ? 25 : 20),
      ),
      elevation: hasGradients ? 4 : 0,
    ),
    dividerTheme: DividerThemeData(
      color: hasGradients ? primaryColor.withOpacity(0.2) : Colors.grey[700],
      thickness: hasGradients ? 0.8 : 0.5,
    ),
    listTileTheme: ListTileThemeData(
      shape:
          hasGradients
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : null,
      tileColor: hasGradients ? primaryColor.withOpacity(0.08) : null,
    ),
  );

  static ThemeProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<ThemeProvider>(context, listen: listen);
  }
}
