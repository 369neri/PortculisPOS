import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(1000),
);

Invoice _makeInvoice(int subunits) => Invoice(
      items: [InvoiceItem(item: TradeItem(sku: 'x', label: 'x', unitPrice: Price.from(subunits)))],
    );

void main() {
  group('PriceCalculator', () {
    test('subtotal returns zero for empty invoice', () {
      const invoice = Invoice();
      expect(PriceCalculator.subtotal(invoice).value, BigInt.zero);
    });

    test('subtotal returns sum of line totals', () {
      final invoice = Invoice(
        items: [
          InvoiceItem(item: _item, quantity: 2),
          InvoiceItem(item: TradeItem(sku: 'y', label: 'y', unitPrice: Price.from(500))),
        ],
      );
      expect(PriceCalculator.subtotal(invoice).value, BigInt.from(2500));
    });

    test('tax returns zero when taxRate is 0', () {
      expect(
        PriceCalculator.tax(_makeInvoice(1000)).value,
        BigInt.zero,
      );
    });

    test('tax returns correct amount for 10% rate', () {
      expect(
        PriceCalculator.tax(_makeInvoice(1000), taxRate: 10).value,
        BigInt.from(100),
      );
    });

    test('grandTotal equals subtotal when taxRate is 0', () {
      final invoice = Invoice(
        items: [
          InvoiceItem(item: _item, quantity: 3),
        ],
      );
      final sub = PriceCalculator.subtotal(invoice);
      final grand = PriceCalculator.grandTotal(invoice);
      expect(grand.value, sub.value);
      expect(grand.value, BigInt.from(3000));
    });

    test('grandTotal includes tax when taxRate > 0', () {
      final invoice = Invoice(
        items: [
          InvoiceItem(item: _item),
        ],
      );
      // 1000 subunits + 10% = 1100
      expect(
        PriceCalculator.grandTotal(invoice, taxRate: 10).value,
        BigInt.from(1100),
      );
    });

    test('grandTotal handles many items', () {
      final invoice = Invoice(
        items: [
          for (var i = 1; i <= 10; i++)
            InvoiceItem(
              item: TradeItem(sku: 'item$i', label: 'Item $i', unitPrice: Price.from(100)),
              quantity: i,
            ),
        ],
      );
      // sum of 1..10 * 100 = 5500
      expect(PriceCalculator.grandTotal(invoice).value, BigInt.from(5500));
    });
  });
}
