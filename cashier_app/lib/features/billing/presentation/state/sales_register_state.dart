import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class SalesRegisterState extends Equatable {
  const SalesRegisterState({
    this.invoice = const Invoice(),
    this.heldInvoices = const [],
  });

  final Invoice invoice;
  final List<Invoice> heldInvoices;

  SalesRegisterState copyWith({
    Invoice? invoice,
    List<Invoice>? heldInvoices,
  }) {
    return SalesRegisterState(
      invoice: invoice ?? this.invoice,
      heldInvoices: heldInvoices ?? this.heldInvoices,
    );
  }

  @override
  List<Object?> get props => [invoice, heldInvoices];
}
