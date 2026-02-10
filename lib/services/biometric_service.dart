import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      // Skúsime zistiť dostupnosť
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      // Ak to padne na Pigeon chybe, tvárime sa, že biometria nie je
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
      // TOTO JE TO KĽÚČOVÉ MIESTO!
      // Tu zachytíme tú chybu "List<Object?> is not subtype..."
      print("Kritická chyba knižnice (Pigeon mismatch): $e");

      // Vrátime true, ak chceš, aby to pri tejto chybe pustilo ďalej (riskantné),
      // alebo false, aby to jednoducho zlyhalo bez pádu appky.
      // Odporúčam vrátiť false a nechať používateľa zadať heslo.
      return false;
    }
  }
}