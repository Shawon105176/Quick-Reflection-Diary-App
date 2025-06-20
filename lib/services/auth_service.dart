import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            Platform.isIOS
                ? 'Please authenticate to access your reflections'
                : 'Use your fingerprint or face to unlock the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return false;
      } else if (e.code == 'NotEnrolled') {
        return false;
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticateWithLocalAuth({String? reason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return false;
      } else if (e.code == 'NotEnrolled') {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
