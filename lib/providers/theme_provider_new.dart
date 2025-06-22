import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../models/app_settings.dart';

enum AppTheme {
  mindfulPurple,
  oceanBlue,
  forestGreen,
  sunsetOrange,
  roseGold,
  charcoalDark,
}

class ThemeProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  AppTheme _currentTheme = AppTheme.mindfulPurple;

  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  AppTheme get currentTheme => _currentTheme;

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
    _currentTheme = theme;
    _settings = _settings.copyWith(selectedTheme: theme.name);
    await StorageService.saveSettings(_settings);
    notifyListeners();
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
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
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
      elevation: 0,
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardTheme(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
    ),
  );
}
