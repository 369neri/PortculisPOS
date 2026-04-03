import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('Invoice', () {
    test('Should create with default active status and empty items', () {
      const invoice = Invoice();
      expect(invoice.status, equals(InvoiceStatus.active));
      expect(invoice.items, isEmpty);
    });

    test('Should add an item immutably', () {
      const invoice = Invoice();
      final item = InvoiceItem(item: KeyedPriceItem(Price.from(500)));
      final updated = invoice.addItem(item);

      expect(updated.items.length, equals(1));
      expect(invoice.items, isEmpty); // original unchanged
    });

    test('Should remove an item by index immutably', () {
      final item1 = InvoiceItem(item: KeyedPriceItem(Price.from(100)));
      final item2 = InvoiceItem(item: KeyedPriceItem(Price.from(200)));
      final invoice = Invoice(items: [item1, item2]);

      final updated = invoice.removeItemAt(0);
      expect(updated.items.length, equals(1));
      expect(updated.items.first, equals(item2));
      expect(invoice.items.length, equals(2)); // original unchanged
    });

    test('Should update item quantity immutably', () {
      final item = InvoiceItem(item: KeyedPriceItem(Price.from(300)));
      final invoice = Invoice(items: [item]);

      final updated = invoice.updateItemQuantity(0, 5);
      expect(updated.items.first.quantity, equals(5));
      expect(invoice.items.first.quantity, equals(1)); // original unchanged
    });

    test('Should calculate total from line items', () {
      final invoice = Invoice(items: [
        InvoiceItem(item: KeyedPriceItem(Price.from(1000)), quantity: 2),
        InvoiceItem(item: KeyedPriceItem(Price.from(500))),
      ],);

      // 1000*2 + 500*1 = 2500
      expect(invoice.total.value, equals(BigInt.from(2500)));
    });

    test('Should return zero total for empty invoice', () {
      const invoice = Invoice();
      expect(invoice.total.value, equals(BigInt.zero));
    });

    test('Should transition to pending on suspend', () {
      const invoice = Invoice();
      final suspended = invoice.suspend();
      expect(suspended.status, equals(InvoiceStatus.pending));
    });

    test('Should transition to active on activate', () {
      const invoice = Invoice(status: InvoiceStatus.pending);
      final activated = invoice.activate();
      expect(activated.status, equals(InvoiceStatus.active));
    });

    test('Should transition to processed on process', () {
      const invoice = Invoice();
      final processed = invoice.process();
      expect(processed.status, equals(InvoiceStatus.processed));
    });

    test('Should transition to cancelled on cancel', () {
      const invoice = Invoice();
      final cancelled = invoice.cancel();
      expect(cancelled.status, equals(InvoiceStatus.cancelled));
    });

    test('Should be equal when items and status match', () {
      final item = InvoiceItem(item: KeyedPriceItem(Price.from(100)));
      final invoice1 = Invoice(items: [item]);
      final invoice2 = Invoice(items: [item]);
      expect(invoice1, equals(invoice2));
    });

    test('Should not be equal when status differs', () {
      const invoice1 = Invoice();
      const invoice2 = Invoice(status: InvoiceStatus.pending);
      expect(invoice1, isNot(equals(invoice2)));
    });

    test('Should create copy with copyWith', () {
      const original = Invoice();
      final copy = original.copyWith(status: InvoiceStatus.processed);
      expect(copy.status, equals(InvoiceStatus.processed));
      expect(copy.items, isEmpty);
    });
  });
}
