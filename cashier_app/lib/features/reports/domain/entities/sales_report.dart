import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class SalesReport extends Equatable {
  const SalesReport({
    required this.periodEnd,
    required this.transactionCount,
    required this.voidedCount,
    required this.grossSales,
    required this.taxEstimated,
    required this.paymentBreakdown,
    this.periodStart,
  });

  /// Start of the period; null means "all time".
  final DateTime? periodStart;

  /// When this report was generated.
  final DateTime periodEnd;

  /// Completed transaction count.
  final int transactionCount;

  /// Voided transaction count.
  final int voidedCount;

  /// Sum of all completed invoice totals.
  final Price grossSales;

  /// Estimated tax component (grossSales × taxRate / 100).
  final Price taxEstimated;

  /// Total paid per payment method.
  final Map<PaymentMethod, Price> paymentBreakdown;

  /// Net sales after subtracting estimated tax.
  Price get netSales => Price(grossSales.value - taxEstimated.value);

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        transactionCount,
        voidedCount,
        grossSales,
        taxEstimated,
        paymentBreakdown,
      ];
}
