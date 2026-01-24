import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

class CryptoService {
  static const _keyName = 'aes_key';
  static final _storage = FlutterSecureStorage();

  /// Načíta alebo vytvorí AES-256 kľúč
  static Future<Key> _getKey() async {
    String? base64Key = await _storage.read(key: _keyName);

    if (base64Key == null) {
      final rand = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => rand.nextInt(256));
      base64Key = Key(Uint8List.fromList(keyBytes)).base64;
      await _storage.write(key: _keyName, value: base64Key);
    }

    return Key.fromBase64(base64Key);
  }

  /// Zašifruje bytes
  static Future<Uint8List> encryptBytes(Uint8List data) async {
    final key = await _getKey();
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encryptBytes(data, iv: iv);

    // uložíme IV + dáta spolu
    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  /// Dešifruje bytes
  static Future<Uint8List> decryptBytes(Uint8List data) async {
    final key = await _getKey();

    final iv = IV(data.sublist(0, 16));
    final encryptedData = data.sublist(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted =
    encrypter.decryptBytes(Encrypted(encryptedData), iv: iv);

    return Uint8List.fromList(decrypted);
  }
}
