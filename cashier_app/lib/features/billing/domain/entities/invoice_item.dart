import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a line on an invoice: an item, quantity, and optional discount.
@immutable
class InvoiceItem extends Equatable {
  const InvoiceItem({
    required this.item,
    this.quantity = 1,
    this.discountPercent = 0.0,
    this.discountAmount,
  });

  final Item item;
  final int quantity;

  /// Percentage discount (0–100) applied to this line item.
  final double discountPercent;

  /// Fixed-amount discount applied to this line item (takes priority over %).
  final Price? discountAmount;

  /// Gross line total before discounts.
  Price get grossTotal => Price(item.unitPrice.value * BigInt.from(quantity));

  /// Net line total after discounts.
  Price get lineTotal {
    final gross = grossTotal;
    if (discountAmount != null) {
      final diff = gross.value - discountAmount!.value;
      return diff > BigInt.zero ? Price(diff) : Price.from(0);
    }
    if (discountPercent > 0) {
      final discountValue =
          gross.value * BigInt.from((discountPercent * 100).round()) ~/
              BigInt.from(10000);
      final diff = gross.value - discountValue;
      return diff > BigInt.zero ? Price(diff) : Price.from(0);
    }
    return gross;
  }

  bool get hasDiscount => discountPercent > 0 || discountAmount != null;

  InvoiceItem copyWith({
    Item? item,
    int? quantity,
    double? discountPercent,
    Price? Function()? discountAmount,
  }) {
    return InvoiceItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount:
          discountAmount != null ? discountAmount() : this.discountAmount,
    );
  }

  @override
  List<Object?> get props => [item, quantity, discountPercent, discountAmount];
}
