import 'dart:math';

import 'package:equatable/equatable.dart';

import 'validation_result.dart';

class Price extends Equatable {
  final BigInt _value;
  BigInt get value => _value;

  // The number of digits after the decimal separator representing subunits.
  // See: https://en.wikipedia.org/wiki/ISO_4217
  // e.g. there are 100 cents to the USD Log(num of cents) = 2
  // e.g. there are 1M Sats to the Bitcoin Log(num of sats) = 6
  final int digits;
  static const int defaultDigits = 2;

  @override // equatable
  List<Object> get props => [value];

  const Price(this._value, {this.digits = defaultDigits}) : super();

  factory Price.from(num price, {digits = defaultDigits}) {
    return Price(BigInt.from(price), digits: digits);
  }

  @override
  String toString() { 
    double val = _value / BigInt.from(pow(10, digits)); // $1 fractions to 100 cents
    return val.toStringAsFixed(digits); // show dollar and cents format ($1.10)
  }

  ValidationResult validate() {
    if (_value.isNegative) {
      return ValidationResult(
        false, 
        field: Field.price, 
        message: 'Price cannot be negative'
      );
    }
    return ValidationResult(true);
  }

}