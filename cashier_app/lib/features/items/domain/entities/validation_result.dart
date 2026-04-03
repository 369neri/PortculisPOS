import 'package:flutter/widgets.dart';

enum Field {
  price,
  gtin,
}

@immutable
class ValidationResult {

  const ValidationResult({required this.isValid, this.field, this.message});
  final bool isValid;
  final Field? field;
  final String? message;
}
