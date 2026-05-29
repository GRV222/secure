import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  String generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String generateIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String encrypt({
    required String content,
    required String keyBase64,
    required String ivBase64,
  }) {
    try {
      final key = enc.Key(Uint8List.fromList(base64Url.decode(keyBase64)));
      final iv = enc.IV(Uint8List.fromList(base64Url.decode(ivBase64)));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.encrypt(content, iv: iv).base64;
    } catch (e) {
      debugPrint('Encryption error: $e');
      return '';
    }
  }

  String decrypt({
    required String encryptedContent,
    required String keyBase64,
    required String ivBase64,
  }) {
    try {
      final key = enc.Key(Uint8List.fromList(base64Url.decode(keyBase64)));
      final iv = enc.IV(Uint8List.fromList(base64Url.decode(ivBase64)));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(encryptedContent, iv: iv);
    } catch (e) {
      debugPrint('Decryption error: $e');
      return '';
    }
  }

  String hashUidList(List<String> uids) {
    final sorted = [...uids]..sort();
    final bytes = utf8.encode(sorted.join(','));
    return sha256.convert(bytes).toString();
  }

  void clearSensitiveData(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
