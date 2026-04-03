import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';

/// Pure service: generates a [SalesReport] from a list of transactions.
class ReportService {
  const ReportService._();

  static SalesReport generate(
    List<Transaction> transactions, {
    DateTime? from,
    double taxRate = 0,
  }) {
    final now = DateTime.now();

    final relevant = from == null
        ? transactions
        : transactions.where((t) => !t.createdAt.isBefore(from)).toList();

    final completed = relevant
        .where((t) => t.status == TransactionStatus.completed)
        .toList();
    final voided = relevant
        .where((t) => t.status == TransactionStatus.voided)
        .toList();

    var grossSales = Price.from(0);
    final breakdown = <PaymentMethod, BigInt>{};

    for (final tx in completed) {
      grossSales = Price(grossSales.value + tx.invoice.total.value);
      for (final p in tx.payments) {
        breakdown[p.method] =
            (breakdown[p.method] ?? BigInt.zero) + p.amount.value;
      }
    }

    // Tax estimate: grossSales * taxRate / 100 (integer maths via ×100 scale)
    final taxSubunits = taxRate > 0
        ? (grossSales.value * BigInt.from((taxRate * 100).round())) ~/
            BigInt.from(10000)
        : BigInt.zero;

    return SalesReport(
      periodStart: from,
      periodEnd: now,
      transactionCount: completed.length,
      voidedCount: voided.length,
      grossSales: grossSales,
      taxEstimated: Price(taxSubunits),
      paymentBreakdown:
          breakdown.map((k, v) => MapEntry(k, Price(v))),
    );
  }
}
