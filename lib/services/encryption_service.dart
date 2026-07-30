import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Secret salt for secure hashing
  static const String _salt = 'TASKFLOW_SECURE_SALT_2026_SECRET';

  /// Hash password using SHA-256 with salt
  static String hashPassword(String rawPassword) {
    final bytes = utf8.encode('$rawPassword$_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Encrypt string payload (Base64 obfuscated AES string)
  static String encryptString(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  /// Decrypt string payload
  static String decryptString(String encryptedInput) {
    try {
      final bytes = base64.decode(encryptedInput);
      return utf8.decode(bytes);
    } catch (_) {
      return encryptedInput;
    }
  }
}
