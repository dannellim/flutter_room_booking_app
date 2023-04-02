import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class CryptoUtils {
  static String _get32Length(String input) {
    if (input.length > 32) return input.substring(0, 32);
    String result = input;
    int index = 0;
    while (result.length < 32) {
      result += result[index];
      index++;
      if (index >= input.length) index = 0;
    }
    return result;
  }

  static String encrypt(String encryptKey, String toEncrypt) {
    final plainText = toEncrypt;
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(encryptKey);
    final key = Key.fromUtf8(_get32Length(encoded));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decrypt(String decryptKey, String toDecrypt) {
    final plainText = toDecrypt;
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(decryptKey);
    final key = Key.fromUtf8(_get32Length(encoded));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(plainText, iv: iv);
    return decrypted;
  }
}
