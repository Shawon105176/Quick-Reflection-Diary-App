import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final settings = themeProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Appearance section
              _buildSectionHeader('Appearance', Icons.palette),
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Choose your preferred theme'),
                  value: settings.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Icon(
                    settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Security section
              _buildSectionHeader('Security', Icons.security),
              Card(
                child: Column(
                  children: [
                    FutureBuilder<bool>(
                      future: AuthService.isBiometricAvailable(),
                      builder: (context, snapshot) {
                        final isAvailable = snapshot.data ?? false;

                        return SwitchListTile(
                          title: const Text('Biometric Lock'),
                          subtitle: Text(
                            isAvailable
                                ? 'Use fingerprint or face unlock'
                                : 'Biometric authentication not available',
                          ),
                          value: settings.isBiometricEnabled && isAvailable,
                          onChanged:
                              isAvailable
                                  ? (value) =>
                                      _toggleBiometric(value, themeProvider)
                                  : null,
                          secondary: const Icon(Icons.fingerprint),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.pin),
                      title: Text(
                        settings.pinCode != null ? 'Change PIN' : 'Set PIN',
                      ),
                      subtitle: Text(
                        settings.pinCode != null
                            ? 'PIN lock is enabled'
                            : 'Secure your app with a 4-digit PIN',
                      ),
                      trailing:
                          settings.pinCode != null
                              ? IconButton(
                                onPressed: () => _removePinLock(themeProvider),
                                icon: const Icon(Icons.remove_circle),
                                tooltip: 'Remove PIN',
                              )
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _changePinLock(themeProvider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications section
              _buildSectionHeader('Notifications', Icons.notifications),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Daily Reminders'),
                      subtitle: const Text(
                        'Get reminded to write your reflection',
                      ),
                      value: settings.isNotificationEnabled,
                      onChanged:
                          (value) => _toggleNotifications(value, themeProvider),
                      secondary: const Icon(Icons.schedule),
                    ),
                    if (settings.isNotificationEnabled) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Reminder Time'),
                        subtitle: Text(
                          'Daily at ${_formatTime(settings.notificationHour, settings.notificationMinute)}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _changeNotificationTime(themeProvider),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data section
              _buildSectionHeader('Data', Icons.storage),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Export Data'),
                      subtitle: const Text('Export your reflections'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _exportData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        'Clear All Data',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      subtitle: const Text(
                        'Permanently delete all reflections',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _clearAllData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About section
              _buildSectionHeader('About', Icons.info),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.auto_stories),
                      title: Text('Mindful'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showHelp,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool value, ThemeProvider themeProvider) async {
    if (value) {
      // Enable biometric
      final authenticated = await AuthService.authenticateWithBiometrics();
      if (authenticated) {
        final newSettings = themeProvider.settings.copyWith(
          isBiometricEnabled: true,
        );
        await themeProvider.updateSettings(newSettings);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric lock enabled')),
          );
        }
      }
    } else {
      // Disable biometric
      final newSettings = themeProvider.settings.copyWith(
        isBiometricEnabled: false,
      );
      await themeProvider.updateSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric lock disabled')),
        );
      }
    }
  }

  Future<void> _changePinLock(ThemeProvider themeProvider) async {
    final newPin = await _showPinDialog();
    if (newPin != null) {
      final newSettings = themeProvider.settings.copyWith(pinCode: newPin);
      await themeProvider.updateSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN lock updated')));
      }
    }
  }

  Future<void> _removePinLock(ThemeProvider themeProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove PIN Lock'),
            content: const Text(
              'Are you sure you want to remove the PIN lock?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final newSettings = themeProvider.settings.copyWith(pinCode: null);
      await themeProvider.updateSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN lock removed')));
      }
    }
  }

  Future<String?> _showPinDialog() async {
    _pinController.clear();

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter a 4-digit PIN to secure your app'),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (_pinController.text.length == 4) {
                    Navigator.of(context).pop(_pinController.text);
                  }
                },
                child: const Text('Set'),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleNotifications(
    bool value,
    ThemeProvider themeProvider,
  ) async {
    if (value) {
      final settings = themeProvider.settings;
      await NotificationService.scheduleDailyReminder(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      );
    } else {
      await NotificationService.cancelDailyReminder();
    }

    final newSettings = themeProvider.settings.copyWith(
      isNotificationEnabled: value,
    );
    await themeProvider.updateSettings(newSettings);
  }

  Future<void> _changeNotificationTime(ThemeProvider themeProvider) async {
    final settings = themeProvider.settings;
    final initialTime = TimeOfDay(
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
    );

    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      final newSettings = settings.copyWith(
        notificationHour: newTime.hour,
        notificationMinute: newTime.minute,
      );
      await themeProvider.updateSettings(newSettings);

      if (settings.isNotificationEnabled) {
        await NotificationService.scheduleDailyReminder(
          hour: newTime.hour,
          minute: newTime.minute,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder time updated to ${_formatTime(newTime.hour, newTime.minute)}',
            ),
          ),
        );
      }
    }
  }

  String _formatTime(int hour, int minute) {
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return timeOfDay.format(context);
  }

  Future<void> _exportData() async {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will permanently delete all your reflections and reset the app. '
              'This action cannot be undone. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete All'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await StorageService.clearAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );

        // Refresh providers
        Provider.of<ThemeProvider>(context, listen: false).updateSettings(
          Provider.of<ThemeProvider>(
            context,
            listen: false,
          ).settings.copyWith(isFirstTime: true),
        );
      }
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to Mindful!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mindful is your personal space for daily reflection and mindfulness. '
                    'Each day, you\'ll receive a thoughtful prompt to guide your reflection.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Daily AI-generated prompts'),
                  Text('• Calendar view of your reflections'),
                  Text('• Secure with biometric or PIN lock'),
                  Text('• Dark and light themes'),
                  Text('• Daily notification reminders'),
                  Text('• Search through your reflections'),
                  SizedBox(height: 16),
                  Text(
                    'Your reflections are stored securely on your device and never shared.',
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}
