import 'dart:math';

import 'package:equatable/equatable.dart';

import 'validation_result.dart';

class Price extends Equatable {
  final BigInt _value;
  BigInt get value => _value;

  @override // equatable
  List<Object> get props => [value];

  // fractional unit - to support cryptocurrency with larger fractional units (1M)
  // e.g. there are 100 cents to the USD Log(num of cents) = 2
  // e.g. there are 1M Sats to the Bitcoin Log(num of sats) = 6
  // the default value for the fractional is 2 (two decimal places) 
  final int fractional;
  static const int defaultFractional = 2;

  const Price(this._value, {this.fractional = defaultFractional}) : super();

  factory Price.from(num price, {fractional = defaultFractional}) {
    return Price(BigInt.from(price), fractional: fractional);
  }

  @override
  String toString() { 
    double val = _value / BigInt.from(pow(10, fractional)); // $1 fractions to 100 cents
    return val.toStringAsFixed(fractional); // show dollar and cents format ($1.10)
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