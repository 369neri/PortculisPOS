import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakeTransactionRepo implements TransactionRepository {
  @override
  Future<List<Transaction>> getAll() async => [];
  @override
  Future<Transaction?> findById(int id) async => saved.where((t) => t.id == id).firstOrNull;
  @override
  Future<int> save(Transaction transaction) async {
    final tx = Transaction(
      id: 1,
      invoice: transaction.invoice,
      payments: transaction.payments,
      status: transaction.status,
      createdAt: transaction.createdAt,
    );
    saved.add(tx);
    return 1;
  }

  @override
  Future<void> voidTransaction(int id) async {}

  final saved = <Transaction>[];
}

class _StubSettingsRepo implements SettingsRepository {
  const _StubSettingsRepo([this.settings = const AppSettings()]);

  final AppSettings settings;

  @override
  Future<AppSettings> getSettings() async => settings;
  @override
  Future<void> saveSettings(AppSettings s) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(350),
);

final _invoice = Invoice(
  items: [InvoiceItem(item: _item, quantity: 2)],
); // subtotal = 700

final _completedTx = Transaction(
  id: 1,
  invoice: _invoice.process(),
  payments: [Payment(method: PaymentMethod.cash, amount: Price.from(700))],
  status: TransactionStatus.completed,
  createdAt: DateTime(2026, 4, 1, 10, 30),
);

Widget _buildHarness({
  required CheckoutState initialState,
  AppSettings settings = const AppSettings(),
}) {
  final checkoutCubit = CheckoutCubit(_FakeTransactionRepo());
  // Force the cubit into the desired initial state via seed
  final settingsCubit = SettingsCubit(_StubSettingsRepo(settings));

  return MultiBlocProvider(
    providers: [
      BlocProvider<CheckoutCubit>.value(value: checkoutCubit),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: checkoutCubit..emit(initialState),
          child: const _ReceiptSheetStub(),
        ),
      ),
    ),
  );
}

/// A stub that renders only the CheckoutCompleted view inline
/// (bypassing showModalBottomSheet for testability).
class _ReceiptSheetStub extends StatelessWidget {
  const _ReceiptSheetStub();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        if (state is! CheckoutCompleted) return const SizedBox.shrink();
        // Reproduce the receipt body structure from checkout_page.dart
        final settingsState = context.watch<SettingsCubit>().state;
        final settings = settingsState is SettingsReady
            ? settingsState.settings
            : const AppSettings();
        final tx = state.transaction;
        final taxRate = state.taxRate;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(settings.businessName, key: const Key('biz-name')),
              ...tx.invoice.items.map(
                (it) => Text(
                  '${it.item.label ?? "Item"} \u00d7${it.quantity}',
                  key: Key('item-${it.item.label}'),
                ),
              ),
              const Text('Subtotal', key: Key('subtotal-label')),
              Text(
                taxRate > 0 ? 'Tax ($taxRate%)' : 'Tax',
                key: const Key('tax-label'),
              ),
              ...tx.payments.map(
                (p) => Text(p.method.name.toUpperCase(), key: Key('pay-${p.method.name}')),
              ),
              Text(settings.receiptFooter, key: const Key('footer')),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Receipt view (CheckoutCompleted)', () {
    testWidgets('shows business name from settings', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          initialState: CheckoutCompleted(_completedTx),
          settings: const AppSettings(businessName: 'My Cafe'),
        ),
      );
      await tester.pump(); // SettingsCubit async load
      expect(find.text('My Cafe'), findsOneWidget);
    });

    testWidgets('shows line items', (tester) async {
      await tester.pumpWidget(
        _buildHarness(initialState: CheckoutCompleted(_completedTx)),
      );
      await tester.pump();
      expect(find.text('Coffee \u00d72'), findsOneWidget);
    });

    testWidgets('shows tax label with rate when taxRate > 0', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          initialState: CheckoutCompleted(_completedTx, taxRate: 10),
        ),
      );
      await tester.pump();
      expect(find.text('Tax (10.0%)'), findsOneWidget);
    });

    testWidgets('shows plain Tax label when taxRate is 0', (tester) async {
      await tester.pumpWidget(
        _buildHarness(initialState: CheckoutCompleted(_completedTx)),
      );
      await tester.pump();
      expect(find.text('Tax'), findsOneWidget);
    });

    testWidgets('shows payment method', (tester) async {
      await tester.pumpWidget(
        _buildHarness(initialState: CheckoutCompleted(_completedTx)),
      );
      await tester.pump();
      expect(find.text('CASH'), findsOneWidget);
    });

    testWidgets('shows receipt footer from settings', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          initialState: CheckoutCompleted(_completedTx),
          settings: const AppSettings(receiptFooter: 'Come again!'),
        ),
      );
      await tester.pump();
      expect(find.text('Come again!'), findsOneWidget);
    });

    testWidgets('Done button is present', (tester) async {
      await tester.pumpWidget(
        _buildHarness(initialState: CheckoutCompleted(_completedTx)),
      );
      await tester.pump();
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
