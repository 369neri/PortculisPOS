import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/pages/transaction_history_page.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
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
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}

  @override
  Future<void> refundTransaction(int id) async {}
}

class _StubSettingsRepo implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async => const AppSettings();
  @override
  Future<void> saveSettings(AppSettings settings) async {}
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _tx = Transaction(
  id: 1,
  invoiceNumber: 'INV-00001',
  invoice: Invoice(
    items: [
      InvoiceItem(
        item: TradeItem(
          sku: 'SKU-001',
          label: 'Coffee',
          unitPrice: Price.from(500),
        ),
      ),
    ],
  ).process(),
  payments: [Payment(method: PaymentMethod.cash, amount: Price.from(500))],
  status: TransactionStatus.completed,
  createdAt: DateTime(2026, 4, 1, 10, 30),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildWidget(TransactionHistoryState seedState) {
  final cubit = TransactionHistoryCubit(_FakeTransactionRepo())
    ..emit(seedState);
  final settingsCubit = SettingsCubit(_StubSettingsRepo());

  return MultiBlocProvider(
    providers: [
      BlocProvider<TransactionHistoryCubit>.value(value: cubit),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
    ],
    child: const MaterialApp(
      home: TransactionHistoryPage(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransactionHistoryPage', () {
    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        _buildWidget(const TransactionHistoryLoading()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows spinner for initial state', (tester) async {
      await tester.pumpWidget(
        _buildWidget(const TransactionHistoryInitial()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty view when loaded with no transactions',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(const TransactionHistoryLoaded([])),
      );
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('shows invoiceNumber in list when loaded', (tester) async {
      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([_tx])),
      );
      expect(find.text('INV-00001'), findsOneWidget);
    });

    testWidgets('shows total in list tile', (tester) async {
      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([_tx])),
      );
      // total = 500 subunits = 5.00 with default \$ symbol
      expect(find.textContaining('5.00'), findsAny);
    });

    testWidgets('shows error message on error state', (tester) async {
      await tester.pumpWidget(
        _buildWidget(const TransactionHistoryError('Connection failed')),
      );
      expect(find.textContaining('Connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows detail sheet on tile tap', (tester) async {
      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([_tx])),
      );

      await tester.tap(find.text('INV-00001'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);

      // Scroll to reveal buttons added below the fold.
      await tester.drag(find.text('Coffee'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Void Transaction'), findsOneWidget);
    });

    testWidgets('detail sheet shows CASH payment', (tester) async {
      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([_tx])),
      );

      await tester.tap(find.text('INV-00001'));
      await tester.pumpAndSettle();

      expect(find.text('CASH'), findsAny);
    });

    testWidgets('detail sheet has Close button', (tester) async {
      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([_tx])),
      );

      await tester.tap(find.text('INV-00001'));
      await tester.pumpAndSettle();

      // Scroll to reveal Close button below the fold.
      await tester.drag(find.text('Coffee'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('does not show Void button for voided transaction',
        (tester) async {
      final voidedTx = Transaction(
        id: 2,
        invoiceNumber: 'INV-00002',
        invoice: _tx.invoice,
        payments: _tx.payments,
        status: TransactionStatus.voided,
        createdAt: DateTime(2026, 4, 2),
      );

      await tester.pumpWidget(
        _buildWidget(TransactionHistoryLoaded([voidedTx])),
      );

      await tester.tap(find.text('INV-00002'));
      await tester.pumpAndSettle();

      expect(find.text('Void Transaction'), findsNothing);
    });
  });
}
