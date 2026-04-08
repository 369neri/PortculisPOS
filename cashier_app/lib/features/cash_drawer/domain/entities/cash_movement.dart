import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CashMovementType { sale, refund, voidTx, adjustment }

@immutable
class CashMovement extends Equatable {
  const CashMovement({
    required this.sessionId,
    required this.type,
    required this.amountSubunits,
    required this.createdAt,
    this.id,
    this.note = '',
  });

  final int? id;
  final int sessionId;
  final CashMovementType type;

  /// Positive for money-in (sale), negative for money-out (refund, void).
  final int amountSubunits;
  final String note;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, sessionId, type, amountSubunits, note, createdAt];
}
