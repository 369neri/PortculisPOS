import 'package:get_it/get_it.dart';

class Price {
  final BigInt _value;
  BigInt get value => _value;

  Price(this._value) : super() {
    throwIf(_value.isNegative, ArgumentError('prices cannot be negative values'));
  }

  factory Price.from(num price) {
    return Price(BigInt.from(price));
  }

}