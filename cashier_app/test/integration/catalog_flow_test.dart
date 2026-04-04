import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/presentation/state/item_catalog_cubit.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late TestDeps deps;

  setUp(() {
    deps = TestDeps();
  });

  tearDown(() => deps.dispose());

  group('Catalog flow (full stack)', () {
    test('save items and list them', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);

      // Load — should include seed data from DB migration
      await catalog.load();
      expect(catalog.state, isA<ItemCatalogLoaded>());
      final seedCount =
          (catalog.state as ItemCatalogLoaded).items.length;

      // Add a new item
      final newItem = TradeItem(
        sku: 'TEST-001',
        label: 'Test Widget',
        unitPrice: Price.from(200),
      );
      await catalog.save(newItem);

      final loaded = catalog.state as ItemCatalogLoaded;
      expect(loaded.items.length, seedCount + 1);
      expect(
        loaded.items.any((i) => i.sku == 'TEST-001'),
        isTrue,
      );

      await catalog.close();
    });

    test('lookup by SKU finds a saved item', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);
      final lookup = ItemLookupCubit(deps.itemRepo);

      final item = TradeItem(
        sku: 'LOOKUP-1',
        label: 'Findable',
        unitPrice: Price.from(200),
      );
      await catalog.save(item);

      await lookup.lookupBySku('LOOKUP-1');
      expect(lookup.state, isA<ItemLookupFound>());
      final found = (lookup.state as ItemLookupFound).item;
      expect(found.sku, 'LOOKUP-1');
      expect(found.label, 'Findable');

      await catalog.close();
      await lookup.close();
    });

    test('lookup by SKU returns not found for unknown', () async {
      final lookup = ItemLookupCubit(deps.itemRepo);

      await lookup.lookupBySku('DOES-NOT-EXIST');
      expect(lookup.state, isA<ItemLookupNotFound>());
      expect(
        (lookup.state as ItemLookupNotFound).query,
        'DOES-NOT-EXIST',
      );

      await lookup.close();
    });

    test('delete item removes it from catalog', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);

      final item = TradeItem(
        sku: 'DEL-001',
        label: 'Deletable',
        unitPrice: Price.from(200),
      );
      await catalog.save(item);
      var loaded = catalog.state as ItemCatalogLoaded;
      final countBefore = loaded.items.length;

      await catalog.deleteBySku('DEL-001');
      loaded = catalog.state as ItemCatalogLoaded;
      expect(loaded.items.length, countBefore - 1);
      expect(
        loaded.items.any((i) => i.sku == 'DEL-001'),
        isFalse,
      );

      await catalog.close();
    });

    test('lookup by GTIN finds item when SKU miss', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);
      final lookup = ItemLookupCubit(deps.itemRepo);

      final item = TradeItem(
        sku: 'GTIN-SKU-1',
        label: 'Barcoded Widget',
        unitPrice: Price.from(500),
        gtin: '5901234123457',
      );
      await catalog.save(item);

      // Lookup by GTIN (as if scanned from barcode).
      await lookup.lookupBySku('5901234123457');
      expect(lookup.state, isA<ItemLookupFound>());
      final found = (lookup.state as ItemLookupFound).item;
      expect(found.sku, 'GTIN-SKU-1');
      expect(found.label, 'Barcoded Widget');

      await catalog.close();
      await lookup.close();
    });

    test('lookup by SKU still takes priority over GTIN', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);
      final lookup = ItemLookupCubit(deps.itemRepo);

      // Item whose SKU happens to look like a GTIN
      final item = TradeItem(
        sku: '5901234123457',
        label: 'SKU-priority',
        unitPrice: Price.from(300),
        gtin: '9780201379624',
      );
      await catalog.save(item);

      await lookup.lookupBySku('5901234123457');
      expect(lookup.state, isA<ItemLookupFound>());
      final found = (lookup.state as ItemLookupFound).item;
      expect(found.label, 'SKU-priority');

      await catalog.close();
      await lookup.close();
    });

    test('upsert updates existing item by SKU', () async {
      final catalog = ItemCatalogCubit(deps.itemRepo);

      final original = TradeItem(
        sku: 'UPD-001',
        label: 'Original',
        unitPrice: Price.from(200),
      );
      await catalog.save(original);

      final updated = TradeItem(
        sku: 'UPD-001',
        label: 'Updated Name',
        unitPrice: Price.from(200),
      );
      await catalog.save(updated);

      final loaded = catalog.state as ItemCatalogLoaded;
      final match = loaded.items.where((i) => i.sku == 'UPD-001').toList();
      expect(match, hasLength(1));
      expect(match.first.label, 'Updated Name');

      await catalog.close();
    });
  });
}
