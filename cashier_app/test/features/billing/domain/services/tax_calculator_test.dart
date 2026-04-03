import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/services/tax_calculator.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

// 1 × Coffee @ $10.00 = 1000 subunits
final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(1000),
);

final _invoice = Invoice(
  items: [InvoiceItem(item: _item)],
);

void main() {
  group('TaxCalculator.calculate', () {
    test('returns zero for 0 % rate', () {
      final tax = TaxCalculator.calculate(_invoice, 0);
      expect(tax.value, BigInt.zero);
    });

    test('returns zero for negative rate', () {
      final tax = TaxCalculator.calculate(_invoice, -5);
      expect(tax.value, BigInt.zero);
    });

    test('10 % on 1000 subunits = 100 subunits', () {
      final tax = TaxCalculator.calculate(_invoice, 10);
      expect(tax.value, BigInt.from(100));
    });

    test('20 % on 1000 subunits = 200 subunits', () {
      final tax = TaxCalculator.calculate(_invoice, 20);
      expect(tax.value, BigInt.from(200));
    });

    test('6.5 % on 1000 subunits = 65 subunits', () {
      final tax = TaxCalculator.calculate(_invoice, 6.5);
      expect(tax.value, BigInt.from(65));
    });

    test('returns zero for empty invoice', () {
      const empty = Invoice();
      final tax = TaxCalculator.calculate(empty, 10);
      expect(tax.value, BigInt.zero);
    });
  });
}
