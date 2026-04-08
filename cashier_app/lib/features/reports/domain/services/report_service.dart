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
    bool taxInclusive = false,
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

    // Tax estimate: depends on whether prices include tax.
    final BigInt taxSubunits;
    if (taxRate <= 0) {
      taxSubunits = BigInt.zero;
    } else {
      final rateBP = BigInt.from((taxRate * 100).round());
      if (taxInclusive) {
        // Back-calculate: tax = gross × rate / (100 + rate)
        final divisor = BigInt.from(10000) + rateBP;
        taxSubunits = (grossSales.value * rateBP) ~/ divisor;
      } else {
        taxSubunits =
            (grossSales.value * rateBP) ~/ BigInt.from(10000);
      }
    }

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
