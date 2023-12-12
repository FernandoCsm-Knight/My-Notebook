import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EncryptionHelper {
  encrypt.Key? key = null;
  encrypt.IV? iv = null;

  Future<void> _loadKeyAndIV() async {
    if(key != null && iv != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString('encryptKey');
    String? ivString = prefs.getString('encryptIV');

    if (keyString == null || ivString == null) {
      key = encrypt.Key.fromSecureRandom(32);
      iv = encrypt.IV.fromSecureRandom(16);
      await prefs.setString('encryptKey', base64Encode(key!.bytes));
      await prefs.setString('encryptIV', base64Encode(iv!.bytes));
    } else {
      key = encrypt.Key(base64Decode(keyString));
      iv = encrypt.IV(base64Decode(ivString));
    }
  }

  Future<String> encryptText(String text) async {
    if (text.isEmpty) {
      return '';
    }

    await _loadKeyAndIV();
    final encrypter = encrypt.Encrypter(encrypt.AES(key!, mode: encrypt.AESMode.cbc));
    return encrypter.encrypt(text, iv: iv).base64;
  }

  Future<String> decryptText(String text) async {
    if (text.isEmpty) {
      return '';
    }

    await _loadKeyAndIV();
    final encrypter = encrypt.Encrypter(encrypt.AES(key!, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt(encrypt.Encrypted.from64(text), iv: iv);
  }
}
