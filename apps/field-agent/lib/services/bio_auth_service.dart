import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BioAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available on this device.
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  /// Get list of available biometrics (Face, Fingerprint, etc.).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return <BiometricType>[];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return <BiometricType>[];
    } catch (e) {
      print('Unexpected error: $e');
      return <BiometricType>[];
    }
  }

  /// Authenticate the user. Returns true if successful.
  Future<bool> authenticate() async {
    if (kIsWeb) return true; // Bypass on web for now, or return false depending on desired flow
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access ResourceRadar Field Agent',
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }
}
