import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_state.dart';
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

  group('Reports flow (full stack)', () {
    Future<void> completeSale({
      required CheckoutCubit cubit,
      required int priceSubunits,
      PaymentMethod method = PaymentMethod.cash,
      double taxRate = 0,
    }) async {
      final item = TradeItem(
        sku: 'RPT-${DateTime.now().microsecondsSinceEpoch}',
        label: 'Report Item',
        unitPrice: Price(BigInt.from(priceSubunits)),
      );
      final invoice = Invoice(items: [InvoiceItem(item: item)]);
      cubit.startCheckout(invoice, taxRate: taxRate);
      final collecting = cubit.state as CheckoutCollecting;
      cubit.addPayment(method, collecting.totalDue);
      await cubit.completeCheckout();
      cubit.reset();
    }

    test('report reflects completed transactions', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);
      final reportsCubit = ReportsCubit(deps.txRepo, deps.settingsRepo);

      // Complete two sales
      await completeSale(cubit: checkoutCubit, priceSubunits: 1000);
      await completeSale(cubit: checkoutCubit, priceSubunits: 2000);

      await reportsCubit.load();
      expect(reportsCubit.state, isA<ReportsReady>());
      final report = (reportsCubit.state as ReportsReady).report;
      expect(report.transactionCount, 2);
      expect(report.grossSales, Price(BigInt.from(3000)));

      await checkoutCubit.close();
      await reportsCubit.close();
    });

    test('report includes tax estimate when tax rate set', () async {
      final settingsCubit = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await settingsCubit.update(const AppSettings(taxRate: 10));
      await settingsCubit.close();

      final checkoutCubit = CheckoutCubit(deps.txRepo);
      // Sale of 1000 at 10% tax → grand total 1100
      await completeSale(
        cubit: checkoutCubit,
        priceSubunits: 1000,
        taxRate: 10,
      );

      final reportsCubit = ReportsCubit(deps.txRepo, deps.settingsRepo);
      await reportsCubit.load();
      final report = (reportsCubit.state as ReportsReady).report;

      // grossSales is the invoice total (1000), taxEstimated = 1000 * 10/100 = 100
      expect(report.transactionCount, 1);
      expect(report.taxEstimated, Price(BigInt.from(100)));

      await checkoutCubit.close();
      await reportsCubit.close();
    });

    test('payment breakdown shows per-method totals', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);

      await completeSale(
        cubit: checkoutCubit,
        priceSubunits: 500,
      );
      await completeSale(
        cubit: checkoutCubit,
        priceSubunits: 300,
        method: PaymentMethod.card,
      );
      await completeSale(
        cubit: checkoutCubit,
        priceSubunits: 200,
      );

      final reportsCubit = ReportsCubit(deps.txRepo, deps.settingsRepo);
      await reportsCubit.load();
      final report = (reportsCubit.state as ReportsReady).report;

      expect(
        report.paymentBreakdown[PaymentMethod.cash],
        Price(BigInt.from(700)),
      );
      expect(
        report.paymentBreakdown[PaymentMethod.card],
        Price(BigInt.from(300)),
      );

      await checkoutCubit.close();
      await reportsCubit.close();
    });

    test('Z report (closeDay) resets period', () async {
      final checkoutCubit = CheckoutCubit(deps.txRepo);
      final reportsCubit = ReportsCubit(deps.txRepo, deps.settingsRepo);

      // Complete a sale
      await completeSale(cubit: checkoutCubit, priceSubunits: 1000);

      // Generate report
      await reportsCubit.load();
      var report = (reportsCubit.state as ReportsReady).report;
      expect(report.transactionCount, 1);

      // Close the day (Z report)
      await reportsCubit.closeDay();
      expect(reportsCubit.state, isA<ReportsReady>());
      final readyState = reportsCubit.state as ReportsReady;
      expect(readyState.lastZAt, isNotNull);

      // After Z report, report shows 0 transactions for new period
      // (the old transaction is before the Z cutoff)
      report = readyState.report;
      expect(report.transactionCount, 0);

      await checkoutCubit.close();
      await reportsCubit.close();
    });
  });
}
