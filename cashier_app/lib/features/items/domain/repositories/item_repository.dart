import 'package:cashier_app/features/items/domain/entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAll();
  Future<Item?> findBySku(String sku);
  Future<Item?> findByGtin(String gtin);
  Future<void> save(Item item);
  Future<void> deleteById(int id);
  Future<void> deleteBySku(String sku);

  // Stock & favorites
  Future<List<Item>> getFavorites();
  Future<void> decrementStock(String sku, {int qty = 1});
  Future<void> incrementStock(String sku, {int qty = 1});
}
