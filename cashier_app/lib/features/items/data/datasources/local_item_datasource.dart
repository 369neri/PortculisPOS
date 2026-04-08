import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:drift/drift.dart';

class LocalItemDatasource implements ItemRepository {
  LocalItemDatasource(this._db);

  final AppDatabase _db;

  @override
  Future<List<Item>> getAll() async {
    final rows = await _db.itemsDao.getAllItems();
    return rows.map(_toItem).toList();
  }

  @override
  Future<Item?> findBySku(String sku) async {
    final row = await _db.itemsDao.findBySku(sku);
    return row == null ? null : _toItem(row);
  }

  @override
  Future<Item?> findByGtin(String gtin) async {
    final row = await _db.itemsDao.findByGtin(gtin);
    return row == null ? null : _toItem(row);
  }

  @override
  Future<void> save(Item item) async {
    if (item.sku == null) return; // KeyedPriceItem is never persisted
    await _db.itemsDao.upsertItem(
      ItemsTableCompanion(
        sku: Value(item.sku!),
        label: Value(item.label ?? ''),
        unitPriceSubunits: Value(item.unitPrice.value.toInt()),
        type: Value(_typeOf(item)),
        gtin: item is TradeItem ? Value(item.gtin) : const Value(null),
        category: Value(item.category),
        stockQuantity: Value(item.stockQuantity),
        isFavorite: Value(item.isFavorite),
        imagePath: Value(item.imagePath),
        itemTaxRate: Value(item.itemTaxRate),
      ),
    );
  }

  @override
  Future<void> deleteById(int id) => _db.itemsDao.deleteItem(id);

  @override
  Future<void> deleteBySku(String sku) async {
    final row = await _db.itemsDao.findBySku(sku);
    if (row != null) await _db.itemsDao.deleteItem(row.id);
  }

  @override
  Future<List<Item>> getFavorites() async {
    final rows = await _db.itemsDao.getFavorites();
    return rows.map(_toItem).toList();
  }

  @override
  Future<void> decrementStock(String sku, {int qty = 1}) =>
      _db.itemsDao.decrementStock(sku, qty);

  @override
  Future<void> incrementStock(String sku, {int qty = 1}) =>
      _db.itemsDao.incrementStock(sku, qty);

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  Item _toItem(ItemsTableData row) {
    final price = Price(BigInt.from(row.unitPriceSubunits));
    return switch (row.type) {
      'service' => ServiceItem(
          sku: row.sku,
          label: row.label,
          unitPrice: price,
          category: row.category,
          isFavorite: row.isFavorite,
          imagePath: row.imagePath,
          itemTaxRate: row.itemTaxRate,
        ),
      _ => TradeItem(
          sku: row.sku,
          label: row.label,
          unitPrice: price,
          gtin: row.gtin,
          category: row.category,
          stockQuantity: row.stockQuantity,
          isFavorite: row.isFavorite,
          imagePath: row.imagePath,
          itemTaxRate: row.itemTaxRate,
        ),
    };
  }

  String _typeOf(Item item) => switch (item) {
        ServiceItem() => 'service',
        TradeItem() => 'trade',
        KeyedPriceItem() => 'keyed',
      };
}
