import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/items/data/datasources/local_item_datasource.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LocalItemDatasource datasource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    datasource = LocalItemDatasource(db);
  });

  tearDown(() async => db.close());

  group('LocalItemDatasource', () {
    test('getAll returns the 4 seeded items', () async {
      final items = await datasource.getAll();
      expect(items.length, 4);
    },);

    test('findBySku SKU-001 returns Coffee trade item', () async {
      final item = await datasource.findBySku('SKU-001');
      expect(item, isNotNull);
      expect(item, isA<TradeItem>());
      expect(item!.label, 'Coffee');
      expect(item.unitPrice.value, BigInt.from(350));
    },);

    test('findBySku SVC-001 returns ServiceItem', () async {
      final item = await datasource.findBySku('SVC-001');
      expect(item, isNotNull);
      expect(item, isA<ServiceItem>());
      expect(item!.label, 'Delivery');
    },);

    test('findBySku unknown sku returns null', () async {
      final item = await datasource.findBySku('DOES-NOT-EXIST');
      expect(item, isNull);
    },);

    test('save inserts new item visible via getAll', () async {
      final newItem = TradeItem(
        sku: 'SKU-NEW',
        label: 'Widget',
        unitPrice: Price.from(999),
      );
      await datasource.save(newItem);
      final items = await datasource.getAll();
      expect(items.length, 5);
      expect(items.any((i) => i.sku == 'SKU-NEW'), isTrue);
    },);

    test('save updates existing item when sku matches', () async {
      final updated = TradeItem(
        sku: 'SKU-001',
        label: 'Espresso',
        unitPrice: Price.from(420),
      );
      await datasource.save(updated);
      final item = await datasource.findBySku('SKU-001');
      expect(item!.label, 'Espresso');
      expect(item.unitPrice.value, BigInt.from(420));
      // Total count unchanged
      expect((await datasource.getAll()).length, 4);
    },);

    test('save ServiceItem is persisted with type service', () async {
      final svc = ServiceItem(
        sku: 'SVC-NEW',
        label: 'Express',
        unitPrice: Price.from(150),
      );
      await datasource.save(svc);
      final found = await datasource.findBySku('SVC-NEW');
      expect(found, isA<ServiceItem>());
    },);

    test('save KeyedPriceItem (no sku) is ignored', () async {
      await datasource.save(KeyedPriceItem(Price.from(500)));
      final items = await datasource.getAll();
      expect(items.length, 4); // seed count unchanged
    },);

    test('deleteById removes the item', () async {
      final rows = await db.itemsDao.getAllItems();
      final coffeeId = rows.firstWhere((r) => r.sku == 'SKU-001').id;
      await datasource.deleteById(coffeeId);
      final found = await datasource.findBySku('SKU-001');
      expect(found, isNull);
      expect((await datasource.getAll()).length, 3);
    },);
  },);
}
