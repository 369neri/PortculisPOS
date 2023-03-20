import 'currency.dart';
import 'item.dart';

class PriceList {
  final List<Item> _items = [];
  final Currency _currency;
  Currency get currency => _currency;

  PriceList(this._currency) : super();

  int countItems() {
    return _items.length;
  }

  void addItem(Item item) {
    _items.add(item);
  }

  void addItems(List<Item> items) {
    _items.addAll(items);
  }

  void insertItem(int index, Item item) {
    _items.insert(index, item);
  }

  void insertItems(int index, List<Item> items) {
    _items.insertAll(index, items);
  }

  void cancelItem(Item item) {
    _items.remove(item);
  }

  void removeItemAt(int index) {
    _items.removeAt(index);
  }

  void clear() {
    _items.clear();
  }
}