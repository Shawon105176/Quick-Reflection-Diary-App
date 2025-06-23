import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/journal_cover_screen.dart';
import '../screens/daily_wellness_screen.dart';
import '../screens/photo_reflection_screen.dart';
import '../screens/wellness_toolkit_screen.dart';
import '../screens/ai_companion_screen.dart';
import '../screens/life_events_timeline_screen.dart';
import '../screens/mental_health_score_screen.dart';
import '../screens/reflection_library_screen.dart';
import '../screens/journal_vault_screen.dart';
import '../screens/daily_mood_weather_screen.dart';
import '../screens/night_mode_timer_screen.dart';
import '../screens/affirmation_garden_screen.dart';
import '../screens/anonymous_reflection_community_screen.dart';
import '../screens/stealth_mode_screen.dart';

class WellnessProviders extends StatelessWidget {
  final Widget child;

  const WellnessProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalCoverProvider()),
        ChangeNotifierProvider(create: (_) => WellnessProvider()),
        ChangeNotifierProvider(create: (_) => PhotoReflectionProvider()),
        ChangeNotifierProvider(create: (_) => WellnessToolkitProvider()),
        ChangeNotifierProvider(create: (_) => AIJournalProvider()),
        ChangeNotifierProvider(create: (_) => LifeEventsProvider()),
        ChangeNotifierProvider(create: (_) => MentalHealthProvider()),
        ChangeNotifierProvider(create: (_) => ReflectionLibraryProvider()),
        ChangeNotifierProvider(create: (_) => JournalExportProvider()),
        ChangeNotifierProvider(create: (_) => DailyMoodWeatherProvider()),
        ChangeNotifierProvider(create: (_) => NightModeTimerProvider()),
        ChangeNotifierProvider(create: (_) => AffirmationGardenProvider()),
        ChangeNotifierProvider(create: (_) => AnonymousReflectionProvider()),
        ChangeNotifierProvider(create: (_) => StealthModeProvider()),
      ],
      child: child,
    );
  }
}
