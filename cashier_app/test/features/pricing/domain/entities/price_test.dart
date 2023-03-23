import 'package:cashier_app/features/pricing/domain/entities/price.dart';
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

    test('Should accept zero as a valid price', () {
      expect(Price.from(0).validate().isValid, equals(true));
    });

    test('Should print string representation as currency', () {
      var price = Price.from(12023);

      expect(price.toString(), equals('120.23'));
    });

    test('Should print crypto fractional prices', () {
      var price = Price.from(32000000, digits: 6); // Sats (Bitcoin), Lovelace (Cardano), etc.

      expect(price.toString(), equals('32.000000'));
    });

    test('Should support zero fractional prices', () {
      var price = Price.from(20488596, digits: 0);

      expect(price.toString(), equals('20488596')); 
    });
  });
}