
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceItem', () {
    test('Should create same hashcode for equatable service items', () {
      final item1 = ServiceItem(sku: 'sku', label: 'My Item', unitPrice: Price.from(256));
      final item2 = ServiceItem(sku: 'sku', label: 'My Item', unitPrice: Price.from(256));

      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('Should validate valid price as true', () {
      final item = ServiceItem(sku: 'svc-1', label: 'Haircut', unitPrice: Price.from(2500));
      expect(item.validate().isValid, isTrue);
    });

    test('Should validate negative price as false', () {
      final item = ServiceItem(sku: 'svc-1', label: 'Haircut', unitPrice: Price.from(-100));
      expect(item.validate().isValid, isFalse);
    });

    test('Should validate zero price as true', () {
      final item = ServiceItem(sku: 'svc-free', label: 'Free Consultation', unitPrice: Price.from(0));
      expect(item.validate().isValid, isTrue);
    });

    test('Should not be equal when sku differs', () {
      final item1 = ServiceItem(sku: 'a', label: 'Same', unitPrice: Price.from(100));
      final item2 = ServiceItem(sku: 'b', label: 'Same', unitPrice: Price.from(100));
      expect(item1, isNot(equals(item2)));
    });

    // -- New field defaults --

    test('defaults: category is empty, isFavorite is false', () {
      final item = ServiceItem(sku: 'x', label: 'x', unitPrice: Price.from(1));
      expect(item.category, '');
      expect(item.isFavorite, false);
    });

    test('stockQuantity is always -1', () {
      final item = ServiceItem(sku: 'x', label: 'x', unitPrice: Price.from(1));
      expect(item.stockQuantity, -1);
    });

    test('items with different category are not equal', () {
      final a = ServiceItem(sku: 's', label: 'l', unitPrice: Price.from(1), category: 'A');
      final b = ServiceItem(sku: 's', label: 'l', unitPrice: Price.from(1), category: 'B');
      expect(a, isNot(equals(b)));
    });

    test('items with different isFavorite are not equal', () {
      final a = ServiceItem(sku: 's', label: 'l', unitPrice: Price.from(1), isFavorite: true);
      final b = ServiceItem(sku: 's', label: 'l', unitPrice: Price.from(1), isFavorite: false);
      expect(a, isNot(equals(b)));
    });
  });
}
