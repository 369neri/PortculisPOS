import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:cashier_app/features/reports/presentation/pages/reports_page.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_state.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakeTxRepo implements TransactionRepository {
  @override
  Future<List<Transaction>> getAll() async => [];
  @override
  Future<List<Transaction>> getPage(int limit, int offset) async => [];
  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction t) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}

  @override
  Future<void> refundTransaction(int id) async {}

  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) async {}

  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async => [];
}

class _StubSettingsRepo implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async => const AppSettings();
  @override
  Future<void> saveSettings(AppSettings s) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SalesReport _report({
  int count = 0,
  int priceSubunits = 0,
}) {
  return SalesReport(
    periodEnd: DateTime(2026, 4),
    transactionCount: count,
    voidedCount: 0,
    grossSales: Price.from(priceSubunits),
    taxEstimated: Price.from(0),
    paymentBreakdown: const {},
  );
}

Widget _buildWidget({
  required ReportsState reportsState,
  TransactionHistoryState historyState = const TransactionHistoryLoaded([]),
}) {
  final reportsCubit =
      ReportsCubit(_FakeTxRepo(), _StubSettingsRepo())..emit(reportsState);
  final historyCubit = TransactionHistoryCubit(_FakeTxRepo())
    ..emit(historyState);
  final settingsCubit = SettingsCubit(_StubSettingsRepo());

  return MultiBlocProvider(
    providers: [
      BlocProvider<ReportsCubit>.value(value: reportsCubit),
      BlocProvider<TransactionHistoryCubit>.value(value: historyCubit),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
    ],
    child: const MaterialApp(home: ReportsPage()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ReportsPage', () {
    testWidgets('shows spinner when reports loading', (tester) async {
      await tester.pumpWidget(_buildWidget(reportsState: const ReportsLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows transaction count chip when ready', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report(count: 5))),
      );
    await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows X Report button when ready', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report())),
      );
    await tester.pumpAndSettle();
      expect(find.text('X Report'), findsOneWidget);
    });

    testWidgets('shows Z Report button when ready', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report())),
      );
    await tester.pumpAndSettle();
      expect(find.text('Z Report — Close Day'), findsOneWidget);
    });

    testWidgets('shows All time when lastZAt is null', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report())),
      );
    await tester.pumpAndSettle();
      expect(find.textContaining('All time'), findsOneWidget);
    });

    testWidgets('shows period start date when lastZAt is set', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          reportsState: ReportsReady(
            report: _report(),
            lastZAt: DateTime(2026, 4, 1, 8),
          ),
        ),
      );
    await tester.pumpAndSettle();
      expect(find.textContaining('2026-04-01'), findsOneWidget);
    });

    testWidgets('tapping X Report opens bottom sheet', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report(count: 3))),
      );
    await tester.pumpAndSettle();

      await tester.tap(find.text('X Report'));
      await tester.pumpAndSettle();

      expect(find.text('X Report'), findsWidgets); // button + sheet title
      expect(find.text('Transactions'), findsWidgets);
    });

    testWidgets('Transactions tab shows empty message', (tester) async {
      await tester.pumpWidget(
        _buildWidget(reportsState: ReportsReady(report: _report())),
      );
    await tester.pumpAndSettle();

      // Switch to Transactions tab
      await tester.tap(find.text('Transactions').last);
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('shows error view with retry button', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          reportsState: const ReportsError('Network error'),
        ),
      );
    await tester.pumpAndSettle();
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
