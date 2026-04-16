import 'package:bakalarka/generated/l10n.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: S.of(context as BuildContext).biometriaTitle,
      );
    } on PlatformException catch (e) {
      return false;
    } catch (e) {

      return false;
    }
  }
}