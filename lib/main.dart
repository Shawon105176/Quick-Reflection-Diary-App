import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/reflections_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/goals_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  GlobalErrorHandler.setup();

  // Initialize storage service first
  try {
    await StorageService.initialize();
  } catch (e) {
    debugPrint('Error initializing storage: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AppErrorBoundary(
      screenName: 'Main App',
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              try {
                return ThemeProvider();
              } catch (e) {
                debugPrint('Error creating ThemeProvider: $e');
                rethrow;
              }
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              try {
                return ReflectionsProvider();
              } catch (e) {
                debugPrint('Error creating ReflectionsProvider: $e');
                rethrow;
              }
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              try {
                return MoodProvider();
              } catch (e) {
                debugPrint('Error creating MoodProvider: $e');
                rethrow;
              }
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              try {
                return GoalsProvider();
              } catch (e) {
                debugPrint('Error creating GoalsProvider: $e');
                rethrow;
              }
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              try {
                return PremiumProvider();
              } catch (e) {
                debugPrint('Error creating PremiumProvider: $e');
                rethrow;
              }
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              try {
                return UserProvider();
              } catch (e) {
                debugPrint('Error creating UserProvider: $e');
                rethrow;
              }
            },
          ),
        ],
        child: SafeConsumer<ThemeProvider>(
          debugLabel: 'Main Theme Consumer',
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Mindful',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              themeMode:
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const AppErrorBoundary(
                screenName: 'Splash Screen',
                child: SplashScreen(),
              ),
              builder: (context, widget) {
                return AppErrorBoundary(
                  screenName: 'App Root',
                  child: widget ?? const SizedBox(),
                );
              },
            );
          },
          errorBuilder: (context, error) {
            return MaterialApp(
              title: 'Mindful',
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('App Error'),
                      const SizedBox(height: 8),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
