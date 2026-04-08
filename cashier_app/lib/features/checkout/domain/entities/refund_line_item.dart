import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a single line-item refund within a partial refund operation.
@immutable
class RefundLineItem extends Equatable {
  const RefundLineItem({
    required this.lineIndex,
    required this.quantity,
    required this.amountSubunits,
    this.reason = '',
  });

  /// Index of the line item in the original invoice.
  final int lineIndex;

  /// Number of units being refunded (1..original qty).
  final int quantity;

  /// Refund amount in subunits for this line.
  final int amountSubunits;

  /// Optional reason for the refund.
  final String reason;

  @override
  List<Object?> get props => [lineIndex, quantity, amountSubunits, reason];
}
