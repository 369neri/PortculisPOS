import 'package:cashier_app/features/items/domain/entities/validation_result.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Price extends Equatable {

  const Price(this._value, {this.digits = defaultDigits}) : super();

  factory Price.from(num price, {int digits = defaultDigits}) {
    return Price(BigInt.from(price), digits: digits);
  }
  final BigInt _value;
  BigInt get value => _value;

  // The number of digits after the decimal separator representing subunits.
  // See: https://en.wikipedia.org/wiki/ISO_4217
  // e.g. there are 100 cents to the USD Log(num of cents) = 2
  // e.g. there are 1M Sats to the Bitcoin Log(num of sats) = 6
  final int digits;
  static const int defaultDigits = 2;

  @override // equatable
  List<Object> get props => [value, digits];

  @override
  String toString() {
    if (digits == 0) return _value.toString();
    final divisor = BigInt.from(10).pow(digits);
    final whole = (_value ~/ divisor).abs();
    final remainder = _value.remainder(divisor).abs();
    final sign = _value.isNegative ? '-' : '';
    return '$sign$whole.${remainder.toString().padLeft(digits, '0')}';
  }

  ValidationResult validate() {
    if (_value.isNegative) {
      return const ValidationResult(
        isValid: false,
        field: Field.price, 
        message: 'Price cannot be negative',
      );
    }
    return const ValidationResult(isValid: true);
  }

}
