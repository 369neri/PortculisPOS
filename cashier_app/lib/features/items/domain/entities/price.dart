import 'package:get_it/get_it.dart';

class Price {
  final BigInt _price;
  BigInt get price => _price;

  Price(this._price) : super() {
    throwIf(_price < BigInt.from(0), ArgumentError("prices cannot be negative"));
  }

  factory Price.fromInt(int price) {
    return Price(BigInt.from(price));
  }

  factory Price.fromDouble(double price) {
    return Price(BigInt.from(price));
  }

}