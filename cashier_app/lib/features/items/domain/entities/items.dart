import 'item.dart';

class Items {
  final List<Item> _items = [];

  Items() : super();

  int count() {
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