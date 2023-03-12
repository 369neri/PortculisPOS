import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('Price', () {
    test('Negative prices should throw error', () {
      expect(() => Price.from(-10), throwsArgumentError);
    });

    test('Can create price from integer', () {
      var price = Price.from(10);
      expect(price.value, BigInt.from(10));
    });

    test('Can create price from double', () {
      var price = Price.from(10.00);
      expect(price.value, BigInt.from(10.00));
    });
  });
}