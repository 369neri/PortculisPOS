import 'package:cashier_app/features/billing/presentation/pages/sales_register_page.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubItemRepo implements ItemRepository {
  @override
  Future<List<Item>> getAll() async => [];
  @override
  Future<Item?> findBySku(String sku) async => null;

  @override
  Future<Item?> findByGtin(String gtin) async => null;
  @override
  Future<void> save(Item item) async {}
  @override
  Future<void> deleteById(int id) async {}
  @override
  Future<void> deleteBySku(String sku) async {}

  @override
  Future<List<Item>> getFavorites() async => [];
  @override
  Future<void> decrementStock(String sku, {int qty = 1}) async {}
  @override
  Future<void> incrementStock(String sku, {int qty = 1}) async {}
}

class _StubSettingsRepo implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async => const AppSettings();
  @override
  Future<void> saveSettings(AppSettings settings) async {}
}

class _StubTransactionRepo implements TransactionRepository {
  @override
  Future<List<Transaction>> getAll() async => [];
  @override
  Future<List<Transaction>> getPage(int limit, int offset) async => [];
  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}

  @override
  Future<void> refundTransaction(int id) async {}

  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) async {}

  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async => [];
}

void main() {
  group('SalesRegisterPage', () {
    late KeypadCubit keypadCubit;
    late SalesRegisterCubit salesRegisterCubit;
    late SettingsCubit settingsCubit;
    late CheckoutCubit checkoutCubit;

    setUp(() {
      keypadCubit = KeypadCubit(const KeypadInitialState());
      salesRegisterCubit = SalesRegisterCubit();
      settingsCubit = SettingsCubit(_StubSettingsRepo());
      checkoutCubit = CheckoutCubit(_StubTransactionRepo());
    });

    Widget buildTestWidget() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<KeypadCubit>.value(value: keypadCubit),
          BlocProvider<SalesRegisterCubit>.value(value: salesRegisterCubit),
          BlocProvider<ItemLookupCubit>(
            create: (_) => ItemLookupCubit(_StubItemRepo()),
          ),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<CheckoutCubit>.value(value: checkoutCubit),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SalesRegisterPage()),
        ),
      );
    }

    testWidgets('shows empty message when no items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(); // let SettingsCubit load
      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets('shows 0.00 in keypad display initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.text('0.00'), findsAny);
    });

    testWidgets('shows keypad buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('enter'), findsOneWidget);
    });

    testWidgets('enter adds keyed item to invoice list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('1'));
      await tester.tap(find.text('5'));
      await tester.tap(find.text('00'));
      await tester.pump();

      await tester.tap(find.text('enter'));
      await tester.pump();

      expect(find.text('Keyed item'), findsOneWidget);
      expect(find.text('No items yet'), findsNothing);
    });

    testWidgets('total updates after adding item', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('2'));
      await tester.tap(find.text('000'));
      await tester.pump();

      await tester.tap(find.text('enter'));
      await tester.pump();

      expect(find.text('20.00'), findsAny);
    });
  });
}
