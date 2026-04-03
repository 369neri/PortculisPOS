
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
  });
}
