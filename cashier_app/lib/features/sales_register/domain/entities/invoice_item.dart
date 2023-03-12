import 'package:cashier_app/features/items/domain/entities/item.dart';

class InvoiceItem {
  late Item _item;
  late int _quantity;

  InvoiceItem(Item item, int quantity) : super() {
    _item = item;
    _quantity = quantity;
  }
}