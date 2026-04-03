import 'dart:collection';

import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/currency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class PriceList extends Equatable {
  const PriceList({required this.currency, this.items = const []});

  final Currency currency;
  final List<Item> items;

  UnmodifiableListView<Item> get unmodifiableItems =>
      UnmodifiableListView(items);

  int get count => items.length;

  Item? findBySku(String sku) {
    for (final item in items) {
      if (item.sku == sku) return item;
    }
    return null;
  }

  PriceList addItem(Item item) => copyWith(items: [...items, item]);

  PriceList addItems(List<Item> newItems) =>
      copyWith(items: [...items, ...newItems]);

  PriceList removeItem(Item item) =>
      copyWith(items: items.where((i) => i != item).toList());

  PriceList removeItemAt(int index) =>
      copyWith(items: [...items]..removeAt(index));

  PriceList copyWith({Currency? currency, List<Item>? items}) {
    return PriceList(
      currency: currency ?? this.currency,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [currency, items];
}
