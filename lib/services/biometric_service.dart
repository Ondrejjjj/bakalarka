import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      print("Chyba dostupnosti (ignorujem): $e");
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      print("Spúšťam biometriu...");
      return await _auth.authenticate(
        localizedReason: 'Priložte prst pre overenie',
      );
    } on PlatformException catch (e) {
      print("Chyba platformy: $e");
      return false;
    } catch (e) {

      print("Kritická chyba knižnice (Pigeon mismatch): $e");


      return false;
    }
  }
}