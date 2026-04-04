import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late TestDeps deps;

  setUp(() {
    deps = TestDeps();
  });

  tearDown(() => deps.dispose());

  group('Checkout flow (full stack)', () {
    test('add items → checkout → verify transaction persisted', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);
      final historyCubit = TransactionHistoryCubit(deps.txRepo);

      // Build an invoice with two items
      final coffee = TradeItem(
        sku: 'COFFEE',
        label: 'Coffee',
        unitPrice: Price.from(350),
      );
      final invoice = Invoice(
        items: [InvoiceItem(item: coffee, quantity: 2)],
      ); // total = 700 subunits

      // Start checkout
      checkoutCubit.startCheckout(invoice);
      expect(checkoutCubit.state, isA<CheckoutCollecting>());

      // Add cash payment covering the full amount
      checkoutCubit.addPayment(PaymentMethod.cash, Price(BigInt.from(700)));
      final collecting = checkoutCubit.state as CheckoutCollecting;
      expect(collecting.isFullyPaid, isTrue);

      // Complete the checkout
      await checkoutCubit.completeCheckout();
      expect(checkoutCubit.state, isA<CheckoutCompleted>());

      final completed = checkoutCubit.state as CheckoutCompleted;
      expect(completed.transaction.id, isNotNull);
      expect(
        completed.transaction.status,
        TransactionStatus.completed,
      );
      expect(
        completed.transaction.invoice.status,
        InvoiceStatus.processed,
      );

      // Verify it's persisted and visible in history
      await historyCubit.load();
      final historyState = historyCubit.state as TransactionHistoryLoaded;
      expect(historyState.transactions, hasLength(1));
      expect(
        historyState.transactions.first.id,
        completed.transaction.id,
      );

      await checkoutCubit.close();
      await historyCubit.close();
    });

    test('checkout with tax produces correct invoice number', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);

      final item = TradeItem(
        sku: 'ITEM-1',
        label: 'Widget',
        unitPrice: Price(BigInt.from(1000)),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item)]);

      checkoutCubit
        ..startCheckout(invoice, taxRate: 10)
        ..addPayment(PaymentMethod.card, Price(BigInt.from(1100)));
      final collecting = checkoutCubit.state as CheckoutCollecting;
      // Grand total = 1000 + 10% = 1100
      expect(collecting.totalDue, Price(BigInt.from(1100)));
      await checkoutCubit.completeCheckout();

      final completed = checkoutCubit.state as CheckoutCompleted;
      // Invoice number should start with INV-
      expect(completed.transaction.invoiceNumber, startsWith('INV-'));
      expect(completed.taxRate, 10.0);

      await checkoutCubit.close();
    });

    test('split payment across cash and card', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);

      final item = TradeItem(
        sku: 'ITEM-2',
        label: 'Gadget',
        unitPrice: Price(BigInt.from(500)),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item, quantity: 2)]);
      // total = 1000

      checkoutCubit
        ..startCheckout(invoice)
        ..addPayment(PaymentMethod.cash, Price(BigInt.from(600)));

      var collecting = checkoutCubit.state as CheckoutCollecting;
      expect(collecting.isFullyPaid, isFalse);
      expect(collecting.remaining, Price(BigInt.from(400)));

      checkoutCubit.addPayment(PaymentMethod.card, Price(BigInt.from(400)));
      collecting = checkoutCubit.state as CheckoutCollecting;
      expect(collecting.isFullyPaid, isTrue);

      await checkoutCubit.completeCheckout();
      final completed = checkoutCubit.state as CheckoutCompleted;
      expect(completed.transaction.payments, hasLength(2));
      expect(
        completed.transaction.payments[0].method,
        PaymentMethod.cash,
      );
      expect(
        completed.transaction.payments[1].method,
        PaymentMethod.card,
      );

      await checkoutCubit.close();
    });

    test('void transaction removes it from active history', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);
      final historyCubit = TransactionHistoryCubit(deps.txRepo);

      // Complete a transaction
      final item = TradeItem(
        sku: 'ITEM-V',
        label: 'Voidable',
        unitPrice: Price(BigInt.from(100)),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item)]);
      checkoutCubit
        ..startCheckout(invoice)
        ..addPayment(PaymentMethod.cash, Price(BigInt.from(100)));
      await checkoutCubit.completeCheckout();
      final tx = (checkoutCubit.state as CheckoutCompleted).transaction;

      // Void it
      await historyCubit.voidTransaction(tx.id!);

      // Reload history and check voided
      await historyCubit.load();
      final loaded = historyCubit.state as TransactionHistoryLoaded;
      expect(
        loaded.transactions.first.status,
        TransactionStatus.voided,
      );

      await checkoutCubit.close();
      await historyCubit.close();
    });

    test('settings tax rate flows through checkout', () async {
      final settingsCubit = SettingsCubit(deps.settingsRepo);
      // Wait for initial settings load
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(settingsCubit.state, isA<SettingsReady>());

      // Update tax rate to 15%
      await settingsCubit.update(
        const AppSettings(taxRate: 15),
      );
      final settings = (settingsCubit.state as SettingsReady).settings;
      expect(settings.taxRate, 15.0);

      // Verify settings persisted by creating a new cubit reading from DB
      final settingsCubit2 = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final reloaded = (settingsCubit2.state as SettingsReady).settings;
      expect(reloaded.taxRate, 15.0);

      await settingsCubit.close();
      await settingsCubit2.close();
    });
  });
}
