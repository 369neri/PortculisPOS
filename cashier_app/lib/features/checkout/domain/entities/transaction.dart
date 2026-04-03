import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Transaction extends Equatable {
  const Transaction({
    required this.invoice,
    required this.payments,
    required this.status,
    required this.createdAt,
    this.id,
    this.invoiceNumber,
  });

  final int? id;
  final String? invoiceNumber;
  final Invoice invoice;
  final List<Payment> payments;
  final TransactionStatus status;
  final DateTime createdAt;

  /// Sum of all payment amounts.
  Price get totalPaid => payments.fold(
        Price.from(0),
        (sum, p) => Price(sum.value + p.amount.value),
      );

  /// Change due back to the customer (positive = overpayment).
  Price get changeDue {
    final diff = totalPaid.value - invoice.total.value;
    return diff > BigInt.zero ? Price(diff) : Price.from(0);
  }

  /// Whether the customer has paid enough.
  bool get isFullyPaid => totalPaid.value >= invoice.total.value;

  @override
  List<Object?> get props => [id, invoiceNumber, invoice, payments, status, createdAt];
}
