import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically random 16-byte hex salt.
String generateSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// One-way hash for user PINs using SHA-256.
///
/// When [salt] is provided the hash is computed over `salt + pin`, making
/// rainbow-table attacks impractical. Raw PINs are never persisted.
String hashPin(String pin, {String salt = ''}) {
  final bytes = utf8.encode('$salt$pin');
  return sha256.convert(bytes).toString();
}
