import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/items/presentation/state/item_catalog_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeRepo implements ItemRepository {
  List<Item> items = [];
  Exception? error;

  @override
  Future<List<Item>> getAll() async {
    if (error != null) throw error!;
    return List.unmodifiable(items);
  }

  @override
  Future<Item?> findBySku(String sku) async => null;

  @override
  Future<Item?> findByGtin(String gtin) async => null;

  @override
  Future<void> save(Item item) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> deleteById(int id) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> deleteBySku(String sku) async {
    if (error != null) throw error!;
  }

  @override
  Future<List<Item>> getFavorites() async => [];
  @override
  Future<void> decrementStock(String sku, {int qty = 1}) async {}
  @override
  Future<void> incrementStock(String sku, {int qty = 1}) async {}
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _item1 = TradeItem(sku: 'A', label: 'Alpha', unitPrice: Price.from(100));
final _item2 = ServiceItem(sku: 'B', label: 'Beta', unitPrice: Price.from(200));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  group('ItemCatalogCubit', () {
    test('initial state is loading', () {
      expect(ItemCatalogCubit(repo).state, const ItemCatalogLoading());
    },);

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'load emits loading then loaded',
      build: () {
        repo.items = [_item1, _item2];
        return ItemCatalogCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        const ItemCatalogLoading(),
        ItemCatalogLoaded([_item1, _item2]),
      ],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'load from already-loaded state emits loading then loaded',
      build: () {
        repo.items = [_item1];
        return ItemCatalogCubit(repo);
      },
      seed: () => const ItemCatalogLoaded([]),
      act: (c) => c.load(),
      expect: () => [
        const ItemCatalogLoading(),
        ItemCatalogLoaded([_item1]),
      ],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'load error emits loading then error',
      build: () {
        repo.error = Exception('fail');
        return ItemCatalogCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        const ItemCatalogLoading(),
        isA<ItemCatalogError>(),
      ],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'save triggers reload and emits loading then loaded',
      build: () {
        repo.items = [_item1, _item2];
        return ItemCatalogCubit(repo);
      },
      seed: () => ItemCatalogLoaded([_item1]),
      act: (c) => c.save(_item2),
      expect: () => [
        const ItemCatalogLoading(),
        ItemCatalogLoaded([_item1, _item2]),
      ],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'save repo error emits error',
      build: () => ItemCatalogCubit(repo),
      seed: () => ItemCatalogLoaded([_item1]),
      act: (c) {
        repo.error = Exception('save failed');
        return c.save(_item1);
      },
      expect: () => [isA<ItemCatalogError>()],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'deleteById triggers reload and emits loading then loaded',
      build: () {
        repo.items = [_item1];
        return ItemCatalogCubit(repo);
      },
      seed: () => ItemCatalogLoaded([_item1, _item2]),
      act: (c) => c.deleteById(1),
      expect: () => [
        const ItemCatalogLoading(),
        ItemCatalogLoaded([_item1]),
      ],
    );

    blocTest<ItemCatalogCubit, ItemCatalogState>(
      'deleteById repo error emits error',
      build: () => ItemCatalogCubit(repo),
      seed: () => ItemCatalogLoaded([_item1]),
      act: (c) {
        repo.error = Exception('delete failed');
        return c.deleteById(99);
      },
      expect: () => [isA<ItemCatalogError>()],
    );
  },);
}
