
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('KeyedPriceItem', () {
    test('Should create same hashcode for equatable keyed-price items', () {
      final item1 = KeyedPriceItem(Price.from(156));
      final item2 = KeyedPriceItem(Price.from(156));

      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('Should validate valid price as true', () {
      final item = KeyedPriceItem(Price.from(999));
      expect(item.validate().isValid, isTrue);
    });

    test('Should validate negative price as false', () {
      final item = KeyedPriceItem(Price.from(-50));
      expect(item.validate().isValid, isFalse);
    });

    test('Should validate zero price as true', () {
      final item = KeyedPriceItem(Price.from(0));
      expect(item.validate().isValid, isTrue);
    });

    test('Should have null sku and label', () {
      final item = KeyedPriceItem(Price.from(100));
      expect(item.sku, isNull);
      expect(item.label, isNull);
    });

    test('Should expose unitPrice correctly', () {
      final price = Price.from(4250);
      final item = KeyedPriceItem(price);
      expect(item.unitPrice, equals(price));
    });
  });
}
