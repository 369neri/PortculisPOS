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

  group('TaxCalculator.calculate (inclusive)', () {
    test('10 % inclusive on 1100 subunits = 100 subunits', () {
      // If price is 1100 and includes 10% tax, tax portion = 1100 * 10 / 110 = 100
      final item = TradeItem(
        sku: 'INC-001',
        label: 'Item',
        unitPrice: Price.from(1100),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item)]);
      final tax = TaxCalculator.calculate(invoice, 10, inclusive: true);
      expect(tax.value, BigInt.from(100));
    });

    test('20 % inclusive on 1200 subunits = 200 subunits', () {
      // 1200 * 20 / 120 = 200
      final item = TradeItem(
        sku: 'INC-002',
        label: 'Item',
        unitPrice: Price.from(1200),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item)]);
      final tax = TaxCalculator.calculate(invoice, 20, inclusive: true);
      expect(tax.value, BigInt.from(200));
    });

    test('returns zero for 0 % rate when inclusive', () {
      final tax = TaxCalculator.calculate(_invoice, 0, inclusive: true);
      expect(tax.value, BigInt.zero);
    });
  });

  group('TaxCalculator.calculate (per-item rates)', () {
    test('uses item-level rate when set, falls back to global', () {
      // Item A: $10.00 with item-specific 5 % → tax 50
      // Item B: $10.00 with no override, global 10 % → tax 100
      // Total tax = 150
      final itemA = TradeItem(
        sku: 'A',
        label: 'A',
        unitPrice: Price.from(1000),
        itemTaxRate: 5,
      );
      final itemB = TradeItem(
        sku: 'B',
        label: 'B',
        unitPrice: Price.from(1000),
      );
      final invoice = Invoice(
        items: [InvoiceItem(item: itemA), InvoiceItem(item: itemB)],
      );
      final tax = TaxCalculator.calculate(invoice, 10);
      expect(tax.value, BigInt.from(150));
    });

    test('per-item rate 0 % makes that item tax-exempt', () {
      // Item with 0 % override → no tax, global rate ignored for that item
      final exempt = TradeItem(
        sku: 'EX',
        label: 'Exempt',
        unitPrice: Price.from(1000),
        itemTaxRate: 0,
      );
      final taxed = TradeItem(
        sku: 'TX',
        label: 'Taxed',
        unitPrice: Price.from(1000),
      );
      final invoice = Invoice(
        items: [InvoiceItem(item: exempt), InvoiceItem(item: taxed)],
      );
      final tax = TaxCalculator.calculate(invoice, 10);
      // Only taxed item contributes: 1000 * 10% = 100
      expect(tax.value, BigInt.from(100));
    });

    test('per-item rates with inclusive mode', () {
      // Item A: $11.00 inclusive at 10 % → tax = 1100 * 1000 / 11000 = 100
      // Item B: $12.00 inclusive at 20 % → tax = 1200 * 2000 / 12000 = 200
      // Total tax = 300
      final itemA = TradeItem(
        sku: 'A',
        label: 'A',
        unitPrice: Price.from(1100),
        itemTaxRate: 10,
      );
      final itemB = TradeItem(
        sku: 'B',
        label: 'B',
        unitPrice: Price.from(1200),
        itemTaxRate: 20,
      );
      final invoice = Invoice(
        items: [InvoiceItem(item: itemA), InvoiceItem(item: itemB)],
      );
      final tax = TaxCalculator.calculate(invoice, 0, inclusive: true);
      expect(tax.value, BigInt.from(300));
    });

    test('all items without override uses flat global rate', () {
      // No item has itemTaxRate set → behaves like flat rate
      final tax = TaxCalculator.calculate(_invoice, 10);
      expect(tax.value, BigInt.from(100));
    });
  });
}
