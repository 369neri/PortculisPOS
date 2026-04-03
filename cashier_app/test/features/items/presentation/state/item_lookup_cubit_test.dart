import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeRepo implements ItemRepository {
  Item? result;
  bool throws = false;

  @override
  Future<List<Item>> getAll() async => [];

  @override
  Future<Item?> findBySku(String sku) async {
    if (throws) throw Exception('db error');
    return result;
  }

  @override
  Future<void> save(Item item) async {}

  @override
  Future<void> deleteById(int id) async {}

  @override
  Future<void> deleteBySku(String sku) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  group('ItemLookupCubit', () {
    test('initial state is idle', () {
      expect(ItemLookupCubit(repo).state, const ItemLookupIdle());
    },);

    blocTest<ItemLookupCubit, ItemLookupState>(
      'blank sku emits idle',
      build: () => ItemLookupCubit(repo),
      act: (c) => c.lookupBySku('   '),
      expect: () => [const ItemLookupIdle()],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'blank sku from found state resets to idle',
      build: () => ItemLookupCubit(repo),
      seed: () => ItemLookupFound(
        TradeItem(sku: 'X', label: 'X', unitPrice: Price.from(0)),
      ),
      act: (c) => c.lookupBySku(''),
      expect: () => [const ItemLookupIdle()],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'known sku emits loading then found',
      build: () {
        repo.result =
            TradeItem(sku: 'SKU-001', label: 'Coffee', unitPrice: Price.from(350));
        return ItemLookupCubit(repo);
      },
      act: (c) => c.lookupBySku('SKU-001'),
      expect: () => [
        const ItemLookupLoading(),
        isA<ItemLookupFound>(),
      ],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'found state carries the correct item',
      build: () {
        repo.result =
            TradeItem(sku: 'SKU-001', label: 'Coffee', unitPrice: Price.from(350));
        return ItemLookupCubit(repo);
      },
      act: (c) => c.lookupBySku('SKU-001'),
      expect: () => [
        const ItemLookupLoading(),
        predicate<ItemLookupState>(
          (s) => s is ItemLookupFound && s.item.sku == 'SKU-001',
          'found with sku SKU-001',
        ),
      ],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'unknown sku emits loading then not found',
      build: () => ItemLookupCubit(repo), // repo returns null by default
      act: (c) => c.lookupBySku('UNKNOWN'),
      expect: () => [
        const ItemLookupLoading(),
        const ItemLookupNotFound('UNKNOWN'),
      ],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'whitespace is stripped from sku before lookup',
      build: () {
        repo.result = ServiceItem(
          sku: 'SVC-1', label: 'Svc', unitPrice: Price.from(100),
        );
        return ItemLookupCubit(repo);
      },
      act: (c) => c.lookupBySku('  SVC-1  '),
      expect: () => [
        const ItemLookupLoading(),
        predicate<ItemLookupState>(
          (s) => s is ItemLookupFound && s.item.sku == 'SVC-1',
          'found with sku SVC-1',
        ),
      ],
    );

    blocTest<ItemLookupCubit, ItemLookupState>(
      'repo exception emits loading then error',
      build: () {
        repo.throws = true;
        return ItemLookupCubit(repo);
      },
      act: (c) => c.lookupBySku('SKU-001'),
      expect: () => [
        const ItemLookupLoading(),
        isA<ItemLookupError>(),
      ],
    );
  },);
}
