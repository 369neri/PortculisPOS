import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/services/report_service.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(500),
);

Transaction _makeTx({
  required int id,
  int priceSubunits = 500,
  PaymentMethod method = PaymentMethod.cash,
  TransactionStatus status = TransactionStatus.completed,
  DateTime? createdAt,
}) {
  final item = TradeItem(
    sku: _item.sku,
    label: _item.label,
    unitPrice: Price.from(priceSubunits),
  );
  final invoice = Invoice(
    items: [InvoiceItem(item: item)],
  ).process();
  return Transaction(
    id: id,
    invoice: invoice,
    payments: status == TransactionStatus.completed
        ? [Payment(method: method, amount: invoice.total)]
        : [],
    status: status,
    createdAt: createdAt ?? DateTime(2026, 4),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ReportService.generate', () {
    test('empty list produces zero report', () {
      final report = ReportService.generate([]);
      expect(report.transactionCount, 0);
      expect(report.voidedCount, 0);
      expect(report.grossSales.value, BigInt.zero);
      expect(report.taxEstimated.value, BigInt.zero);
      expect(report.paymentBreakdown, isEmpty);
    });

    test('sums gross sales from completed transactions only', () {
      final txs = [
        _makeTx(id: 1, priceSubunits: 1000),
        _makeTx(id: 2),
        _makeTx(id: 3, status: TransactionStatus.voided),
      ];
      final report = ReportService.generate(txs);
      expect(report.grossSales.value, BigInt.from(1500));
      expect(report.transactionCount, 2);
      expect(report.voidedCount, 1);
    });

    test('payment breakdown aggregates by method', () {
      final txs = [
        _makeTx(id: 1, priceSubunits: 1000),
        _makeTx(id: 2, method: PaymentMethod.card),
        _makeTx(id: 3, priceSubunits: 200),
      ];
      final report = ReportService.generate(txs);
      expect(
        report.paymentBreakdown[PaymentMethod.cash]?.value,
        BigInt.from(1200),
      );
      expect(
        report.paymentBreakdown[PaymentMethod.card]?.value,
        BigInt.from(500),
      );
    });

    test('tax estimate at 10% on 1000 subunits = 100 subunits', () {
      final txs = [_makeTx(id: 1, priceSubunits: 1000)];
      final report = ReportService.generate(txs, taxRate: 10);
      expect(report.taxEstimated.value, BigInt.from(100));
    });

    test('tax estimate is zero when taxRate is 0', () {
      final txs = [_makeTx(id: 1, priceSubunits: 1000)];
      final report = ReportService.generate(txs);
      expect(report.taxEstimated.value, BigInt.zero);
    });

    test('netSales = grossSales - taxEstimated', () {
      final txs = [_makeTx(id: 1, priceSubunits: 1000)];
      final report = ReportService.generate(txs, taxRate: 10);
      expect(report.netSales.value, BigInt.from(900));
    });

    test('from filter excludes transactions before cutoff', () {
      final cutoff = DateTime(2026, 4, 2);
      final txs = [
        _makeTx(id: 1, createdAt: DateTime(2026, 4)), // before
        _makeTx(id: 2, createdAt: DateTime(2026, 4, 2)), // exactly at cutoff
        _makeTx(id: 3, createdAt: DateTime(2026, 4, 3)), // after
      ];
      final report = ReportService.generate(txs, from: cutoff);
      expect(report.transactionCount, 2);
      expect(report.grossSales.value, BigInt.from(1000));
    });

    test('from: null includes all transactions', () {
      final txs = [
        _makeTx(id: 1, createdAt: DateTime(2025)),
        _makeTx(id: 2, createdAt: DateTime(2026)),
      ];
      final report = ReportService.generate(txs);
      expect(report.transactionCount, 2);
    });

    test('periodStart matches from parameter', () {
      final from = DateTime(2026, 4);
      final report = ReportService.generate([], from: from);
      expect(report.periodStart, from);
    });
  });
}
