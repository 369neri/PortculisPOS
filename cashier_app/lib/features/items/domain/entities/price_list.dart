import '../../../pricing/domain/entities/currency.dart';
import 'item.dart';

class PriceList {
  final List<Item> _items = [];
  final Currency _currency;
  Currency get currency => _currency;

  PriceList(this._currency) : super();

  int countItems() => _items.length;

  void addItem(Item item) => _items.add(item);
  void addItems(List<Item> items) => _items.addAll(items);

  void insertItem(int index, Item item) => _items.insert(index, item);
  void insertItems(int index, List<Item> items) => _items.insertAll(index, items);

  void removeItem(Item item) => _items.remove(item);
  void removeItemAt(int index) => _items.removeAt(index);

  void clearItems() => _items.clear();
}