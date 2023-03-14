import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('Price', () {
    test('Negative prices should throw FormatException', () {
      expect(() => Price.from(-10), throwsFormatException);
    });

    test('Can create price from integer using named constructor Price.from', () {
      var price = Price.from(10);
      expect(price.value, equals(BigInt.from(10)));
    });

    test('Can create price from double using named constructor Price.from', () {
      var price = Price.from(10.00);
      expect(price.value, equals(BigInt.from(10.00)));
    });

    test('Can create price with BigInt using default constructor', () {
      var price = Price(BigInt.from(1000));
      expect(price.value, equals(BigInt.from(1000)));
    });
  });
}