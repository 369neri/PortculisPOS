import 'dart:convert';

import 'package:crypto/crypto.dart';

/// One-way hash for user PINs using SHA-256.
///
/// The result is a hex-encoded digest so it can be stored as a plain string
/// in the database. Raw PINs are never persisted.
String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  return sha256.convert(bytes).toString();
}
