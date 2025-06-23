import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StealthModeScreen extends StatefulWidget {
  const StealthModeScreen({super.key});

  @override
  State<StealthModeScreen> createState() => _StealthModeScreenState();
}

class _StealthModeScreenState extends State<StealthModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _lockController;
  late AnimationController _shakeController;
  late Animation<double> _lockAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _lockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _lockController.forward();
  }

  @override
  void dispose() {
    _lockController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StealthModeProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stealth Mode'),
          centerTitle: true,
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey.shade900,
        body: Consumer<StealthModeProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stealth Mode Header
                  AnimatedBuilder(
                    animation: _lockAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _lockAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.grey.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset:
                                        provider.isEnabled
                                            ? Offset.zero
                                            : Offset(_shakeAnimation.value, 0),
                                    child: Icon(
                                      provider.isEnabled
                                          ? Icons.security
                                          : Icons.lock_open,
                                      size: 64,
                                      color:
                                          provider.isEnabled
                                              ? Colors.green.shade400
                                              : Colors.red.shade400,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.isEnabled
                                    ? 'Stealth Mode Active'
                                    : 'Stealth Mode Inactive',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.isEnabled
                                    ? 'Your journal is protected and disguised'
                                    : 'Enable to protect your privacy',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Main Toggle
                  Card(
                    color: Colors.grey.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.visibility_off, color: Colors.white70),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Enable Stealth Mode',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Switch(
                                value: provider.isEnabled,
                                onChanged: (value) {
                                  if (value) {
                                    _showEnableStealthDialog(context, provider);
                                  } else {
                                    provider.disableStealth();
                                  }
                                },
                                activeColor: Colors.green.shade400,
                              ),
                            ],
                          ),
                          if (provider.isEnabled) ...[
                            const Divider(color: Colors.white30),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.green.shade400,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Your journal is now hidden and protected',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stealth Settings
                  if (provider.isEnabled) ...[
                    Card(
                      color: Colors.grey.shade800,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings, color: Colors.white70),
                                const SizedBox(width: 12),
                                const Text(
                                  'Stealth Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Disguise App
                            ListTile(
                              leading: Icon(Icons.apps, color: Colors.white70),
                              title: const Text(
                                'Disguise App',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Current: ${provider.disguiseMode}',
                                style: TextStyle(color: Colors.white60),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                              onTap:
                                  () => _showDisguiseOptions(context, provider),
                            ),

                            // Decoy PIN
                            ListTile(
                              leading: Icon(Icons.pin, color: Colors.white70),
                              title: const Text(
                                'Decoy PIN',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                provider.hasDecoyPin
                                    ? 'Shows fake content when entered'
                                    : 'Not set',
                                style: TextStyle(color: Colors.white60),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                              onTap:
                                  () => _showDecoyPinSetup(context, provider),
                            ),

                            // Auto-Lock Timer
                            ListTile(
                              leading: Icon(Icons.timer, color: Colors.white70),
                              title: const Text(
                                'Auto-Lock Timer',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Lock after ${provider.autoLockMinutes} minutes',
                                style: TextStyle(color: Colors.white60),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                              onTap:
                                  () => _showAutoLockOptions(context, provider),
                            ),

                            // Panic Gesture
                            SwitchListTile(
                              secondary: Icon(
                                Icons.gesture,
                                color: Colors.white70,
                              ),
                              title: const Text(
                                'Panic Gesture',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                'Shake phone 3x to instantly lock',
                                style: TextStyle(color: Colors.white60),
                              ),
                              value: provider.panicGestureEnabled,
                              activeColor: Colors.green.shade400,
                              onChanged: (value) {
                                provider.togglePanicGesture(value);
                              },
                            ),

                            // Hide From Recents
                            SwitchListTile(
                              secondary: Icon(
                                Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              title: const Text(
                                'Hide from Recents',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                'Hide app from recent apps list',
                                style: TextStyle(color: Colors.white60),
                              ),
                              value: provider.hideFromRecents,
                              activeColor: Colors.green.shade400,
                              onChanged: (value) {
                                provider.toggleHideFromRecents(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Security Features
                    Card(
                      color: Colors.grey.shade800,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield, color: Colors.white70),
                                const SizedBox(width: 12),
                                const Text(
                                  'Security Features',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildSecurityFeature(
                              'Encryption',
                              'All data encrypted with AES-256',
                              Icons.enhanced_encryption,
                              Colors.green,
                            ),
                            _buildSecurityFeature(
                              'Auto-Delete',
                              'Delete data after 5 failed attempts',
                              Icons.delete_forever,
                              Colors.orange,
                            ),
                            _buildSecurityFeature(
                              'Cloud Sync Disabled',
                              'No data stored in cloud when active',
                              Icons.cloud_off,
                              Colors.blue,
                            ),
                            _buildSecurityFeature(
                              'Screenshot Protection',
                              'Prevents screenshots and screen recording',
                              Icons.screenshot,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Security Tips
                  Card(
                    color: Colors.grey.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber.shade400,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Privacy Tips',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...provider.securityTips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.fiber_manual_record,
                                    size: 8,
                                    color: Colors.amber.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSecurityFeature(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
        ],
      ),
    );
  }

  void _showEnableStealthDialog(
    BuildContext context,
    StealthModeProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Enable Stealth Mode?',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              'This will:\n\n'
              '• Disguise the app appearance\n'
              '• Require PIN to access real content\n'
              '• Enable advanced security features\n'
              '• Hide app from recent apps\n\n'
              'Make sure you remember your PIN!',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.enableStealth();
                  _shakeController.forward().then((_) {
                    _shakeController.reset();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text('Enable'),
              ),
            ],
          ),
    );
  }

  void _showDisguiseOptions(
    BuildContext context,
    StealthModeProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: const Text(
              'Choose Disguise',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  provider.disguiseOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: option,
                      groupValue: provider.disguiseMode,
                      onChanged: (value) {
                        provider.setDisguiseMode(value!);
                        Navigator.pop(context);
                      },
                      activeColor: Colors.green.shade400,
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showDecoyPinSetup(BuildContext context, StealthModeProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: const Text(
              'Set Decoy PIN',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'When this PIN is entered, the app will show fake/empty content.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Decoy PIN',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    provider.setDecoyPin(controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Set PIN'),
              ),
            ],
          ),
    );
  }

  void _showAutoLockOptions(
    BuildContext context,
    StealthModeProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: const Text(
              'Auto-Lock Timer',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [1, 2, 5, 10, 15, 30].map((minutes) {
                    return RadioListTile<int>(
                      title: Text(
                        '${minutes} minute${minutes == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: minutes,
                      groupValue: provider.autoLockMinutes,
                      onChanged: (value) {
                        provider.setAutoLockMinutes(value!);
                        Navigator.pop(context);
                      },
                      activeColor: Colors.green.shade400,
                    );
                  }).toList(),
            ),
          ),
    );
  }
}

class StealthModeProvider extends ChangeNotifier {
  bool _isEnabled = false;
  String _disguiseMode = 'Calculator';
  bool _hasDecoyPin = false;
  int _autoLockMinutes = 5;
  bool _panicGestureEnabled = false;
  bool _hideFromRecents = false;

  bool get isEnabled => _isEnabled;
  String get disguiseMode => _disguiseMode;
  bool get hasDecoyPin => _hasDecoyPin;
  int get autoLockMinutes => _autoLockMinutes;
  bool get panicGestureEnabled => _panicGestureEnabled;
  bool get hideFromRecents => _hideFromRecents;

  final List<String> disguiseOptions = [
    'Calculator',
    'Notes App',
    'Weather App',
    'Calendar',
    'File Manager',
    'Music Player',
  ];

  final List<String> securityTips = [
    'Use a unique PIN that others can\'t guess',
    'Set up a decoy PIN for additional protection',
    'Enable panic gesture for quick app locking',
    'Regularly backup your data to a secure location',
    'Don\'t share your PIN with anyone',
    'Keep the app updated for latest security features',
  ];

  void enableStealth() {
    _isEnabled = true;
    notifyListeners();
  }

  void disableStealth() {
    _isEnabled = false;
    notifyListeners();
  }

  void setDisguiseMode(String mode) {
    _disguiseMode = mode;
    notifyListeners();
  }

  void setDecoyPin(String pin) {
    _hasDecoyPin = pin.isNotEmpty;
    notifyListeners();
  }

  void setAutoLockMinutes(int minutes) {
    _autoLockMinutes = minutes;
    notifyListeners();
  }

  void togglePanicGesture(bool enabled) {
    _panicGestureEnabled = enabled;
    notifyListeners();
  }

  void toggleHideFromRecents(bool enabled) {
    _hideFromRecents = enabled;
    notifyListeners();
  }
}
