import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Skontroluje, či zariadenie podporuje biometriu (Android aj iOS)
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();

      return canAuthenticateWithBiometrics || isSupported;
    } catch (e) {
      print("Chyba pri zisťovaní biometrie: $e");
      return false;
    }
  }

  // 2. Samotné overenie (Univerzálne pre odtlačok aj FaceID)
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Overte sa pre prístup k Trezoru', // Na iOS sa toto zobrazí pri FaceID
      );
    } on PlatformException catch (e) {
      print("Chyba platformy: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      print("Všeobecná chyba: $e");
      return false;
    }
  }
}