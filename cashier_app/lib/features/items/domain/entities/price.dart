import 'package:cashier_app/core/validation_result.dart';

class Price {
  final BigInt _value;
  BigInt get value => _value;

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