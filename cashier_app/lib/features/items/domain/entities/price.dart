import 'package:equatable/equatable.dart';

import '../../../../core/validation_result.dart';

class Price extends Equatable {
  final BigInt _value;
  BigInt get value => _value;

  @override
  List<Object> get props => [value];

  Price(this._value) : super();

  factory Price.from(num price) {
    return Price(BigInt.from(price));
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