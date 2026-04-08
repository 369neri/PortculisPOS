import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Hashes a PIN with the given salt using SHA-256.
String hashPin(String pin, String salt) {
  final bytes = utf8.encode('$salt$pin');
  return sha256.convert(bytes).toString();
}

/// Creates a JWT for the given user.
String createToken(
  String secret, {
  required int userId,
  required String tenantId,
  required String username,
  required String role,
}) {
  final jwt = JWT({
    'sub': userId,
    'tid': tenantId,
    'usr': username,
    'rol': role,
  });
  return jwt.sign(
    SecretKey(secret),
    expiresIn: const Duration(hours: 12),
  );
}

/// Verifies a JWT and returns the payload, or null if invalid.
Map<String, dynamic>? verifyToken(String secret, String token) {
  try {
    final jwt = JWT.verify(token, SecretKey(secret));
    return jwt.payload as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
