import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_state.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakeTxRepo implements TransactionRepository {
  _FakeTxRepo([List<Transaction>? store]) : _store = store ?? [];

  final List<Transaction> _store;
  bool throws = false;

  @override
  Future<List<Transaction>> getAll() async {
    if (throws) throw Exception('db error');
    return List.unmodifiable(_store);
  }

  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}

  @override
  Future<void> refundTransaction(int id) async {}
}

class _FakeSettingsRepo implements SettingsRepository {
  _FakeSettingsRepo([AppSettings? settings])
      : _settings = settings ?? const AppSettings();

  AppSettings _settings;
  bool throws = false;

  @override
  Future<AppSettings> getSettings() async {
    if (throws) throw Exception('settings error');
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    if (throws) throw Exception('settings error');
    _settings = settings;
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _tx = Transaction(
  id: 1,
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
  createdAt: DateTime(2026, 4),
);

// Minimal SalesReport for seeding
SalesReport _emptyReport() => SalesReport(
      periodEnd: DateTime(2026),
      transactionCount: 0,
      voidedCount: 0,
      grossSales: Price.from(0),
      taxEstimated: Price.from(0),
      paymentBreakdown: const {},
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ReportsCubit', () {
    test('initial state is ReportsInitial', () {
      expect(
        ReportsCubit(_FakeTxRepo(), _FakeSettingsRepo()).state,
        const ReportsInitial(),
      );
    });

    blocTest<ReportsCubit, ReportsState>(
      'load() emits loading then ready with empty report',
      build: () => ReportsCubit(_FakeTxRepo(), _FakeSettingsRepo()),
      act: (c) => c.load(),
      expect: () => [
        const ReportsLoading(),
        isA<ReportsReady>()
            .having((s) => s.report.transactionCount, 'count', 0)
            .having((s) => s.lastZAt, 'lastZAt', isNull),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'load() emits ready with correct transaction count and gross sales',
      build: () => ReportsCubit(_FakeTxRepo([_tx]), _FakeSettingsRepo()),
      act: (c) => c.load(),
      expect: () => [
        const ReportsLoading(),
        isA<ReportsReady>()
            .having((s) => s.report.transactionCount, 'count', 1)
            .having(
              (s) => s.report.grossSales.value,
              'grossSales',
              BigInt.from(500),
            ),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'load() passes lastZReportAt from settings',
      build: () {
        final lastZ = DateTime(2026);
        return ReportsCubit(
          _FakeTxRepo(),
          _FakeSettingsRepo(AppSettings(lastZReportAt: lastZ)),
        );
      },
      act: (c) => c.load(),
      expect: () => [
        const ReportsLoading(),
        isA<ReportsReady>().having(
          (s) => s.lastZAt,
          'lastZAt',
          DateTime(2026),
        ),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'load() emits error when tx repo throws',
      build: () {
        final repo = _FakeTxRepo()..throws = true;
        return ReportsCubit(repo, _FakeSettingsRepo());
      },
      act: (c) => c.load(),
      expect: () => [const ReportsLoading(), isA<ReportsError>()],
    );

    blocTest<ReportsCubit, ReportsState>(
      'closeDay() updates lastZReportAt then reloads',
      build: () => ReportsCubit(_FakeTxRepo(), _FakeSettingsRepo()),
      seed: () => ReportsReady(report: _emptyReport()),
      act: (c) => c.closeDay(),
      expect: () => [
        const ReportsLoading(),
        isA<ReportsReady>().having((s) => s.lastZAt, 'lastZAt', isNotNull),
      ],
    );

    blocTest<ReportsCubit, ReportsState>(
      'closeDay() does nothing when not in ready state',
      build: () => ReportsCubit(_FakeTxRepo(), _FakeSettingsRepo()),
      act: (c) => c.closeDay(),
      expect: () => <ReportsState>[],
    );

    blocTest<ReportsCubit, ReportsState>(
      'closeDay() emits error when settings repo throws',
      build: () {
        final settings = _FakeSettingsRepo()..throws = true;
        return ReportsCubit(_FakeTxRepo(), settings);
      },
      seed: () => ReportsReady(report: _emptyReport()),
      act: (c) => c.closeDay(),
      expect: () => [isA<ReportsError>()],
    );
  });
}
