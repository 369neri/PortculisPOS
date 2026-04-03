import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class InvoiceItem extends Equatable {
  const InvoiceItem({required this.item, this.quantity = 1});

  final Item item;
  final int quantity;

  Price get lineTotal => Price(item.unitPrice.value * BigInt.from(quantity));

  InvoiceItem copyWith({Item? item, int? quantity}) {
    return InvoiceItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [item, quantity];
}
