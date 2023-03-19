import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('Price', () {
    test('Should validate as false when price is negative', () {
      var price = Price.from(-10).validate();
      expect(price.isValid, equals(false));
    });

    test('Should create price from integer value using named constructor Price.from', () {
      var price = Price.from(10);
      expect(price.value, equals(BigInt.from(10)));
    });

    test('Should create price from double value using named constructor Price.from', () {
      var price = Price.from(10.00);
      expect(price.value, equals(BigInt.from(10.00)));
    });

    test('Should create price with BigInt value using default constructor', () {
      var price = Price(BigInt.from(1000));
      expect(price.value, equals(BigInt.from(1000)));
    });

    test('Should create same hashcode for two equatable prices', () {
      var price1 = Price.from(210);
      var price2 = Price.from(210);

      expect(price1.hashCode, equals(price2.hashCode));
    });
  });
}