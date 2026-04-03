import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class SalesRegisterState extends Equatable {
  const SalesRegisterState({this.invoice = const Invoice()});

  final Invoice invoice;

  SalesRegisterState copyWith({Invoice? invoice}) {
    return SalesRegisterState(invoice: invoice ?? this.invoice);
  }

  @override
  List<Object?> get props => [invoice];
}
