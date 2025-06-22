import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  String get userName => _settings.userName;
  bool get hasUserName => _settings.userName.isNotEmpty;

  UserProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final settings = StorageService.getSettings();
    _settings = settings;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _settings = _settings.copyWith(userName: name.trim());
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  String getPersonalizedGreeting() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    if (hasUserName) {
      return '$greeting, ${userName}!';
    } else {
      return '$greeting!';
    }
  }

  String getWelcomeMessage() {
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    final dayOfWeek =
        [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][now.weekday - 1];

    List<String> messages = [];

    if (hasUserName) {
      if (hour < 6) {
        messages = [
          'Early bird, ${userName}! Ready to start your day?',
          'Hello ${userName}, you\'re up early today!',
          'Good to see you, ${userName}! How are you feeling?',
        ];
      } else if (hour < 12) {
        messages = [
          'Good morning, ${userName}! Ready for a great ${dayOfWeek}?',
          'Hello ${userName}! How are you feeling this morning?',
          'Morning ${userName}! Let\'s make today amazing!',
          'Rise and shine, ${userName}! What\'s your mood today?',
        ];
      } else if (hour < 17) {
        messages = [
          'Good afternoon, ${userName}! How has your day been?',
          'Hello ${userName}! Ready to reflect on your day?',
          'Hi ${userName}! How are you feeling this afternoon?',
          'Hey ${userName}! Time for some mindful reflection!',
        ];
      } else if (hour < 21) {
        messages = [
          'Good evening, ${userName}! How was your day?',
          'Hello ${userName}! Ready to unwind and reflect?',
          'Evening ${userName}! Let\'s capture today\'s moments.',
          'Hi ${userName}! Time to wind down and reflect.',
        ];
      } else {
        messages = [
          'Good night, ${userName}! How are you feeling?',
          'Hello ${userName}! Ready for some peaceful reflection?',
          'Evening ${userName}! Let\'s end the day mindfully.',
          'Hi ${userName}! Time for some late-night thoughts.',
        ];
      }
    } else {
      if (hour < 6) {
        messages = [
          'Early bird! Ready to start your day?',
          'You\'re up early today! How are you feeling?',
          'Good to see you! Ready for some reflection?',
        ];
      } else if (hour < 12) {
        messages = [
          'Good morning! Ready for a great ${dayOfWeek}?',
          'Hello! How are you feeling this morning?',
          'Morning! Let\'s make today amazing!',
          'Rise and shine! What\'s your mood today?',
        ];
      } else if (hour < 17) {
        messages = [
          'Good afternoon! How has your day been?',
          'Hello! Ready to reflect on your day?',
          'Hi! How are you feeling this afternoon?',
          'Hey! Time for some mindful reflection!',
        ];
      } else if (hour < 21) {
        messages = [
          'Good evening! How was your day?',
          'Hello! Ready to unwind and reflect?',
          'Evening! Let\'s capture today\'s moments.',
          'Hi! Time to wind down and reflect.',
        ];
      } else {
        messages = [
          'Good night! How are you feeling?',
          'Hello! Ready for some peaceful reflection?',
          'Evening! Let\'s end the day mindfully.',
          'Hi! Time for some late-night thoughts.',
        ];
      }
    }

    // Return a random message
    return messages[DateTime.now().millisecond % messages.length];
  }
}
