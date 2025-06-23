import 'package:flutter/material.dart';

/// Base class for all providers with enhanced error handling and safety
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;
  String? _errorMessage;

  bool get isDisposed => _disposed;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Safe version of notifyListeners that prevents notifications after disposal
  @override
  void notifyListeners() {
    if (!_disposed) {
      try {
        super.notifyListeners();
      } catch (e) {
        debugPrint('Error in notifyListeners (${runtimeType}): $e');
        _setError(e.toString());
      }
    }
  }

  /// Safe version of dispose that prevents multiple disposal
  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      try {
        super.dispose();
      } catch (e) {
        debugPrint('Error in dispose (${runtimeType}): $e');
      }
    }
  }

  /// Set an error state for this provider
  void _setError(String error) {
    _errorMessage = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Clear any error state
  void clearError() {
    _errorMessage = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Execute a function safely with error handling
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    if (_disposed) return null;

    try {
      clearError();
      return await operation();
    } catch (e) {
      debugPrint(
        'Error in ${operationName ?? 'operation'} (${runtimeType}): $e',
      );
      _setError(e.toString());
      return null;
    }
  }

  /// Execute a synchronous function safely with error handling
  T? safeExecuteSync<T>(T Function() operation, {String? operationName}) {
    if (_disposed) return null;

    try {
      clearError();
      return operation();
    } catch (e) {
      debugPrint(
        'Error in ${operationName ?? 'operation'} (${runtimeType}): $e',
      );
      _setError(e.toString());
      return null;
    }
  }
}

/// Mixin for safer state management
mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  /// Safe setState that checks if widget is mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        debugPrint('Error in safeSetState (${widget.runtimeType}): $e');
      }
    }
  }
}

/// Mixin for safe animation controller management
mixin SafeAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final List<AnimationController> _controllers = [];
  bool _disposed = false;

  /// Create and register an animation controller for safe disposal
  AnimationController createSafeAnimationController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    TickerProvider? vsync,
  }) {
    final controller = AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
      vsync: vsync ?? this,
    );
    _controllers.add(controller);
    return controller;
  }

  /// Safely dispose all animation controllers
  void disposeSafeAnimationControllers() {
    if (_disposed) return;
    _disposed = true;

    for (final controller in _controllers) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint('Error disposing animation controller: $e');
      }
    }
    _controllers.clear();
  }

  @override
  void dispose() {
    disposeSafeAnimationControllers();
    super.dispose();
  }
}
