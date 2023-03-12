// ignore_for_file: unused_field

import 'package:cashier_app/features/items/domain/entities/item.dart';

class InvoiceItem {
  final Item _item;
  int _quantity;

  InvoiceItem(this._item, this._quantity) : super();

  void updateQuantity(int value) {
    _quantity = value;
  }
}