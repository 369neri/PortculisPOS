import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class CashDrawerSession extends Equatable {
  const CashDrawerSession({
    required this.openedAt,
    required this.openingBalance,
    this.id,
    this.closedAt,
    this.closingBalance,
    this.notes,
  });

  final int? id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final Price openingBalance;
  final Price? closingBalance;
  final String? notes;

  bool get isOpen => closedAt == null;

  @override
  List<Object?> get props => [
        id,
        openedAt,
        closedAt,
        openingBalance,
        closingBalance,
        notes,
      ];
}
