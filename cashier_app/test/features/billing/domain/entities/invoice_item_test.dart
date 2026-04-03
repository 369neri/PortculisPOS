import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('InvoiceItem', () {
    test('Should create with default quantity of 1', () {
      final item = InvoiceItem(item: KeyedPriceItem(Price.from(500)));
      expect(item.quantity, equals(1));
    });

    test('Should create with custom quantity', () {
      final item = InvoiceItem(
        item: KeyedPriceItem(Price.from(500)),
        quantity: 3,
      );
      expect(item.quantity, equals(3));
    });

    test('Should calculate lineTotal as unitPrice * quantity', () {
      final item = InvoiceItem(
        item: KeyedPriceItem(Price.from(250)),
        quantity: 4,
      );
      // 250 * 4 = 1000
      expect(item.lineTotal.value, equals(BigInt.from(1000)));
    });

    test('Should calculate lineTotal for quantity of 1', () {
      final item = InvoiceItem(item: KeyedPriceItem(Price.from(750)));
      expect(item.lineTotal.value, equals(BigInt.from(750)));
    });

    test('Should create copy with updated quantity via copyWith', () {
      final original = InvoiceItem(item: KeyedPriceItem(Price.from(100)));
      final updated = original.copyWith(quantity: 10);

      expect(updated.quantity, equals(10));
      expect(original.quantity, equals(1)); // original unchanged
      expect(updated.item, equals(original.item));
    });

    test('Should be equal when item and quantity match', () {
      final price = Price.from(300);
      final item1 = InvoiceItem(item: KeyedPriceItem(price), quantity: 2);
      final item2 = InvoiceItem(item: KeyedPriceItem(price), quantity: 2);
      expect(item1, equals(item2));
    });

    test('Should not be equal when quantity differs', () {
      final price = Price.from(300);
      final item1 = InvoiceItem(item: KeyedPriceItem(price));
      final item2 = InvoiceItem(item: KeyedPriceItem(price), quantity: 2);
      expect(item1, isNot(equals(item2)));
    });

    test('Should expose item reference', () {
      final keyedItem = KeyedPriceItem(Price.from(999));
      final invoiceItem = InvoiceItem(item: keyedItem);
      expect(invoiceItem.item, equals(keyedItem));
    });
  });
}
