import 'package:flutter/widgets.dart';

enum Field {
  price,
  gtin,
}

@immutable
class ValidationResult {
  final bool isValid;
  final Field? field;
  final String? message;

  const ValidationResult(this.isValid, {this.field, this.message});
}