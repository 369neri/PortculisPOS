import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  group('SalesRegisterCubit', () {
    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'emits empty invoice on creation',
      build: SalesRegisterCubit.new,
      verify: (cubit) {
        expect(cubit.state.invoice.items, isEmpty);
        expect(cubit.state.invoice.status, InvoiceStatus.active);
      },
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'addKeyedItem adds a KeyedPriceItem to the invoice',
      build: SalesRegisterCubit.new,
      act: (cubit) => cubit.addKeyedItem(Price.from(1500)),
      expect: () => [
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 1)
            .having(
              (s) => s.invoice.items.first.item,
              'item type',
              isA<KeyedPriceItem>(),
            )
            .having(
              (s) => s.invoice.items.first.item.unitPrice.value,
              'unitPrice',
              BigInt.from(1500),
            ),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'addKeyedItem with quantity creates item with that quantity',
      build: SalesRegisterCubit.new,
      act: (cubit) => cubit.addKeyedItem(Price.from(500), quantity: 3),
      expect: () => [
        isA<SalesRegisterState>()
            .having(
              (s) => s.invoice.items.first.quantity,
              'quantity',
              3,
            )
            .having(
              (s) => s.invoice.items.first.lineTotal.value,
              'lineTotal',
              BigInt.from(1500),
            ),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'addCatalogItem adds a catalog item to the invoice',
      build: SalesRegisterCubit.new,
      act: (cubit) => cubit.addCatalogItem(
        ServiceItem(
          sku: 'SVC-001',
          label: 'Haircut',
          unitPrice: Price.from(100),
        ),
      ),
      // ServiceItem requires a valid Price — let's check it lands in the invoice
      expect: () => [
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 1)
            .having(
              (s) => s.invoice.items.first.item.label,
              'label',
              'Haircut',
            ),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'multiple addKeyedItem calls accumulate items',
      build: SalesRegisterCubit.new,
      act: (cubit) {
        cubit
          ..addKeyedItem(Price.from(100))
          ..addKeyedItem(Price.from(200))
          ..addKeyedItem(Price.from(300));
      },
      expect: () => [
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 1),
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 2),
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 3),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'removeItem removes item at given index',
      build: SalesRegisterCubit.new,
      seed: () {
        final cubit = SalesRegisterCubit()
          ..addKeyedItem(Price.from(100))
          ..addKeyedItem(Price.from(200));
        return cubit.state;
      },
      act: (cubit) => cubit.removeItem(0),
      expect: () => [
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items.length, 'items.length', 1)
            .having(
              (s) => s.invoice.items.first.item.unitPrice.value,
              'remaining item price',
              BigInt.from(200),
            ),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'updateQuantity changes quantity of item at index',
      build: SalesRegisterCubit.new,
      seed: () {
        final cubit = SalesRegisterCubit()..addKeyedItem(Price.from(500));
        return cubit.state;
      },
      act: (cubit) => cubit.updateQuantity(0, 5),
      expect: () => [
        isA<SalesRegisterState>()
            .having(
              (s) => s.invoice.items.first.quantity,
              'quantity',
              5,
            )
            .having(
              (s) => s.invoice.total.value,
              'total',
              BigInt.from(2500),
            ),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'updateQuantity with 0 removes item',
      build: SalesRegisterCubit.new,
      seed: () {
        final cubit = SalesRegisterCubit()..addKeyedItem(Price.from(500));
        return cubit.state;
      },
      act: (cubit) => cubit.updateQuantity(0, 0),
      expect: () => [
        isA<SalesRegisterState>()
            .having((s) => s.invoice.items, 'items', isEmpty),
      ],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'clearInvoice resets to empty invoice',
      build: SalesRegisterCubit.new,
      seed: () {
        final cubit = SalesRegisterCubit()
          ..addKeyedItem(Price.from(100))
          ..addKeyedItem(Price.from(200));
        return cubit.state;
      },
      act: (cubit) => cubit.clearInvoice(),
      expect: () => [const SalesRegisterState()],
    );

    blocTest<SalesRegisterCubit, SalesRegisterState>(
      'running total is correct after add and remove',
      build: SalesRegisterCubit.new,
      act: (cubit) {
        cubit
          ..addKeyedItem(Price.from(1000))
          ..addKeyedItem(Price.from(2000))
          ..removeItem(0);
      },
      verify: (cubit) {
        expect(cubit.state.invoice.total.value, BigInt.from(2000));
      },
    );
  });
}
