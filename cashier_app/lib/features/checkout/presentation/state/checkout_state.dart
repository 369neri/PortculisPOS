import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
sealed class CheckoutState extends Equatable {
  const CheckoutState();
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();

  @override
  List<Object?> get props => [];
}

final class CheckoutCollecting extends CheckoutState {
  const CheckoutCollecting({
    required this.invoice,
    this.payments = const [],
    this.taxRate = 0.0,
    this.taxInclusive = false,
    this.customerId,
    this.customerName,
  });

  final Invoice invoice;
  final List<Payment> payments;

  /// Tax rate as a percentage (e.g. 10.0 = 10 %).
  final double taxRate;

  /// Whether prices already include tax.
  final bool taxInclusive;

  /// Optional associated customer.
  final int? customerId;
  final String? customerName;

  Price get totalDue => PriceCalculator.grandTotal(invoice,
      taxRate: taxRate, taxInclusive: taxInclusive,);

  Price get totalPaid => payments.fold(
        Price.from(0),
        (sum, p) => Price(sum.value + p.amount.value),
      );

  Price get remaining {
    final diff = totalDue.value - totalPaid.value;
    return diff > BigInt.zero ? Price(diff) : Price.from(0);
  }

  bool get isFullyPaid => totalPaid.value >= totalDue.value;

  Price get changeDue {
    final diff = totalPaid.value - totalDue.value;
    return diff > BigInt.zero ? Price(diff) : Price.from(0);
  }

  @override
  List<Object?> get props =>
      [invoice, payments, taxRate, taxInclusive, customerId, customerName];
}

final class CheckoutCompleted extends CheckoutState {
  const CheckoutCompleted(this.transaction,
      {this.taxRate = 0.0, this.taxInclusive = false,});

  final Transaction transaction;

  /// Tax rate used during this sale (percentage).
  final double taxRate;

  /// Whether prices already include tax.
  final bool taxInclusive;

  @override
  List<Object?> get props => [transaction, taxRate, taxInclusive];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
