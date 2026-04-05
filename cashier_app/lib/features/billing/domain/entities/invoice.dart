import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Invoice extends Equatable {
  const Invoice({
    this.items = const [],
    this.status = InvoiceStatus.active,
  });

  final List<InvoiceItem> items;
  final InvoiceStatus status;

  Price get total => items.fold(
        Price.from(0),
        (sum, item) => Price(sum.value + item.lineTotal.value),
      );

  Invoice addItem(InvoiceItem item) =>
      copyWith(items: [...items, item]);

  Invoice removeItemAt(int index) =>
      copyWith(items: [...items]..removeAt(index));

  Invoice updateItemQuantity(int index, int quantity) {
    final updated = [...items];
    updated[index] = updated[index].copyWith(quantity: quantity);
    return copyWith(items: updated);
  }


  Invoice updateItemDiscount(
    int index, {
    double discountPercent = 0.0,
    Price? discountAmount,
  }) {
    final updated = [...items];
    updated[index] = updated[index].copyWith(
      discountPercent: discountPercent,
      discountAmount: discountAmount != null ? () => discountAmount : null,
    );
    return copyWith(items: updated);
  }

  /// Sum of all line-item discounts (gross totals − net totals).
  Price get discountTotal => items.fold(
        Price.from(0),
        (sum, item) =>
            Price(sum.value + (item.grossTotal.value - item.lineTotal.value)),
      );

  Invoice suspend() => copyWith(status: InvoiceStatus.pending);
  Invoice activate() => copyWith(status: InvoiceStatus.active);
  Invoice process() => copyWith(status: InvoiceStatus.processed);
  Invoice cancel() => copyWith(status: InvoiceStatus.cancelled);

  Invoice copyWith({
    List<InvoiceItem>? items,
    InvoiceStatus? status,
  }) {
    return Invoice(
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [items, status];
}
