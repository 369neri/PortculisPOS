import 'package:equatable/equatable.dart';

enum Field {
  price,
  gtin,
}

class ValidationResult {
  final bool isValid;
  final Field? field;
  final String? message;

  ValidationResult(this.isValid, {this.field, this.message});
}