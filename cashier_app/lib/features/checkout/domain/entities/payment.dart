import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Payment extends Equatable {
  const Payment({
    required this.method,
    required this.amount,
  });

  final PaymentMethod method;
  final Price amount;

  @override
  List<Object?> get props => [method, amount];
}
