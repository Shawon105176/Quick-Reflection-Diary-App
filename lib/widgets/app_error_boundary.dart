import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/safe_provider_base.dart';

/// Global error boundary widget that wraps providers and screens
/// with comprehensive error handling to prevent app crashes
class AppErrorBoundary extends StatelessWidget {
  final Widget child;
  final String screenName;

  const AppErrorBoundary({
    super.key,
    required this.child,
    this.screenName = 'Unknown Screen',
  });

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryWrapper(screenName: screenName, child: child);
  }
}

class _ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;

  const _ErrorBoundaryWrapper({required this.child, required this.screenName});

  @override
  State<_ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<_ErrorBoundaryWrapper>
    with SafeStateMixin {
  bool _hasError = false;
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorUI(context);
    }

    try {
      return widget.child;
    } catch (e) {
      debugPrint('Caught error in ${widget.screenName}: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          safeSetState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      });
      return _buildErrorUI(context);
    }
  }

  Widget _buildErrorUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error - ${widget.screenName}'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We encountered an error in ${widget.screenName}. Please try again.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Error details: ${_errorMessage!.length > 200 ? _errorMessage!.substring(0, 200) + "..." : _errorMessage!}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      safeSetState(() {
                        _hasError = false;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Safe Consumer widget that handles provider errors gracefully
class SafeConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T provider, Widget? child)
  builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget? child;
  final String? debugLabel;

  const SafeConsumer({
    super.key,
    required this.builder,
    this.errorBuilder,
    this.child,
    this.debugLabel,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return Consumer<T>(
        builder: (context, provider, child) {
          try {
            return builder(context, provider, child);
          } catch (e) {
            debugPrint(
              'Error in SafeConsumer ${debugLabel ?? T.toString()}: $e',
            );
            return errorBuilder?.call(context, e) ??
                _buildDefaultError(context, e);
          }
        },
        child: child,
      );
    } catch (e) {
      debugPrint(
        'Error creating SafeConsumer ${debugLabel ?? T.toString()}: $e',
      );
      return errorBuilder?.call(context, e) ?? _buildDefaultError(context, e);
    }
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.red.shade600),
          const SizedBox(height: 8),
          Text(
            'Error loading ${debugLabel ?? 'content'}',
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please try refreshing',
            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Safe provider wrapper that prevents provider exceptions
class SafeChangeNotifierProvider<T extends ChangeNotifier>
    extends StatelessWidget {
  final T Function() create;
  final Widget child;
  final bool lazy;

  const SafeChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
    this.lazy = true,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return ChangeNotifierProvider<T>(
        create: (_) {
          try {
            return create();
          } catch (e) {
            debugPrint('Error creating provider ${T.toString()}: $e');
            rethrow;
          }
        },
        lazy: lazy,
        child: child,
      );
    } catch (e) {
      debugPrint(
        'Error setting up SafeChangeNotifierProvider ${T.toString()}: $e',
      );
      return Container(
        color: Colors.red.shade50,
        child: const Center(child: Text('Provider Error')),
      );
    }
  }
}

/// Global error handler for the entire app
class GlobalErrorHandler {
  static void setup() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FlutterError: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');

      // In production, you might want to send this to crash reporting
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Handle errors outside of Flutter framework
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red.shade600),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please restart the app',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    };
  }
}

/// Safe StatefulWidget base class with error handling
abstract class SafeStatefulWidget extends StatefulWidget {
  const SafeStatefulWidget({super.key});

  @override
  SafeStatefulWidgetState createState();
}

abstract class SafeStatefulWidgetState<T extends SafeStatefulWidget>
    extends State<T> {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Safe setState that checks if widget is mounted and not disposed
  void safeSetState(VoidCallback fn) {
    if (mounted && !_disposed) {
      try {
        setState(fn);
      } catch (e) {
        debugPrint('Error in safeSetState (${widget.runtimeType}): $e');
      }
    }
  }

  /// Safe build method with error boundary
  @override
  Widget build(BuildContext context) {
    try {
      return buildSafe(context);
    } catch (e) {
      debugPrint('Error in build method: $e');
      return Container(
        color: Colors.red.shade50,
        child: const Center(child: Text('Build Error')),
      );
    }
  }

  /// Override this instead of build()
  Widget buildSafe(BuildContext context);
}
