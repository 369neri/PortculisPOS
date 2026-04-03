import 'package:cashier_app/features/items/domain/entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAll();
  Future<Item?> findBySku(String sku);
  Future<void> save(Item item);
  Future<void> deleteById(int id);
  Future<void> deleteBySku(String sku);
}
