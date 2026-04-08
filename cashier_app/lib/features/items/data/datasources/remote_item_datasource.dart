import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

/// Remote datasource that proxies [ItemRepository] calls to the server API.
class RemoteItemDatasource implements ItemRepository {
  RemoteItemDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<Item>> getAll() async {
    final data = await _api.get('/api/items/');
    final items = data['items'] as List? ?? [];
    return items.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Item?> findBySku(String sku) async {
    try {
      final items = await getAll();
      return items.where((i) => i.sku == sku).firstOrNull;
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<Item?> findByGtin(String gtin) async {
    final items = await getAll();
    return items.whereType<TradeItem>().where((i) => i.gtin == gtin).firstOrNull;
  }

  @override
  Future<void> save(Item item) async {
    if (item.sku == null) return;
    await _api.post('/api/items/', _toJson(item));
  }

  @override
  Future<void> deleteById(int id) => _api.delete('/api/items/$id');

  @override
  Future<void> deleteBySku(String sku) async {
    // Server doesn't expose delete-by-sku, so find the id first.
    final items = await getAll();
    final match = items.where((i) => i.sku == sku).firstOrNull;
    if (match != null) {
      // We need the server id. For now, fall back to fetching all and matching.
      // This is a limitation — remote items have server-side ids.
      final data = await _api.get('/api/items/');
      final rawItems = data['items'] as List? ?? [];
      for (final raw in rawItems) {
        final m = raw as Map<String, dynamic>;
        if (m['sku'] == sku) {
          await _api.delete('/api/items/${m['id']}');
          return;
        }
      }
    }
  }

  @override
  Future<List<Item>> getFavorites() async {
    final items = await getAll();
    return items.where((i) => i.isFavorite).toList();
  }

  @override
  Future<void> decrementStock(String sku, {int qty = 1}) async {
    final data = await _api.get('/api/items/');
    final rawItems = data['items'] as List? ?? [];
    for (final raw in rawItems) {
      final m = raw as Map<String, dynamic>;
      if (m['sku'] == sku) {
        await _api.patch('/api/items/${m['id']}/stock', {'delta': -qty});
        return;
      }
    }
  }

  @override
  Future<void> incrementStock(String sku, {int qty = 1}) async {
    final data = await _api.get('/api/items/');
    final rawItems = data['items'] as List? ?? [];
    for (final raw in rawItems) {
      final m = raw as Map<String, dynamic>;
      if (m['sku'] == sku) {
        await _api.patch('/api/items/${m['id']}/stock', {'delta': qty});
        return;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static Item _fromJson(Map<String, dynamic> m) {
    final price = Price(BigInt.from((m['unitPriceSubunits'] as num?) ?? 0));
    final type = m['type'] as String? ?? 'trade';
    if (type == 'service') {
      return ServiceItem(
        sku: m['sku'] as String? ?? '',
        label: m['label'] as String? ?? '',
        unitPrice: price,
        category: m['category'] as String? ?? '',
        isFavorite: m['isFavorite'] as bool? ?? false,
        imagePath: m['imagePath'] as String?,
        itemTaxRate: (m['itemTaxRate'] as num?)?.toDouble(),
      );
    }
    return TradeItem(
      sku: m['sku'] as String? ?? '',
      label: m['label'] as String? ?? '',
      unitPrice: price,
      gtin: m['gtin'] as String?,
      category: m['category'] as String? ?? '',
      stockQuantity: (m['stockQuantity'] as num?)?.toInt() ?? -1,
      isFavorite: m['isFavorite'] as bool? ?? false,
      imagePath: m['imagePath'] as String?,
      itemTaxRate: (m['itemTaxRate'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> _toJson(Item item) {
    return {
      'sku': item.sku,
      'label': item.label,
      'unitPriceSubunits': item.unitPrice.value.toInt(),
      'type': switch (item) {
        ServiceItem() => 'service',
        TradeItem() => 'trade',
        KeyedPriceItem() => 'keyed',
      },
      if (item is TradeItem) 'gtin': item.gtin,
      'category': item.category,
      'stockQuantity': item.stockQuantity,
      'isFavorite': item.isFavorite,
      'imagePath': item.imagePath,
      'itemTaxRate': item.itemTaxRate,
    };
  }
}
