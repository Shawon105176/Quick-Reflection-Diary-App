import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import 'main_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tryBiometricAuth();
  }

  Future<void> _tryBiometricAuth() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final settings = themeProvider.settings;

    if (settings.isBiometricEnabled) {
      final isAvailable = await AuthService.isBiometricAvailable();
      if (isAvailable) {
        final authenticated = await AuthService.authenticateWithBiometrics();
        if (authenticated && mounted) {
          _navigateToMain();
        }
      }
    }
  }

  Future<void> _authenticateWithPin() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final settings = themeProvider.settings;

    if (_pinController.text == settings.pinCode) {
      _navigateToMain();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
      _pinController.clear();
    }
  }

  Future<void> _retryBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authenticated = await AuthService.authenticateWithBiometrics();
    if (authenticated && mounted) {
      _navigateToMain();
    } else {
      setState(() {
        _errorMessage = 'Authentication failed. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please authenticate to access your reflections',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final settings = themeProvider.settings;

                  return Column(
                    children: [
                      // PIN Authentication
                      if (settings.pinCode != null) ...[
                        TextField(
                          controller: _pinController,
                          decoration: InputDecoration(
                            labelText: 'Enter PIN',
                            border: const OutlineInputBorder(),
                            errorText:
                                _errorMessage.isNotEmpty ? _errorMessage : null,
                          ),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          onSubmitted: (_) => _authenticateWithPin(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _authenticateWithPin,
                            child: const Text('Unlock'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Biometric Authentication
                      if (settings.isBiometricEnabled) ...[
                        if (settings.pinCode != null)
                          Text(
                            'OR',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<BiometricType>>(
                          future: AuthService.getAvailableBiometrics(),
                          builder: (context, snapshot) {
                            final biometricType =
                                snapshot.data != null &&
                                        snapshot.data!.isNotEmpty
                                    ? AuthService.getBiometricTypeString(
                                      snapshot.data!,
                                    )
                                    : 'Biometric';

                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _retryBiometric,
                                icon:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.fingerprint),
                                label: Text('Use $biometricType'),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
