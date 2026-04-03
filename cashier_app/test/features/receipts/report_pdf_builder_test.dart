import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/receipts/report_pdf_builder.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final report = SalesReport(
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 1, 31, 23, 59),
    transactionCount: 42,
    voidedCount: 2,
    grossSales: Price.from(15000),
    taxEstimated: Price.from(1363),
    paymentBreakdown: {
      PaymentMethod.cash: Price.from(10000),
      PaymentMethod.card: Price.from(5000),
    },
  );

  const settings = AppSettings(
    businessName: 'Test Cafe',
    receiptFooter: 'Thank you!',
  );

  group('ReportPdfBuilder', () {
    test('build() X report returns non-empty bytes', () async {
      final bytes = await ReportPdfBuilder.build(report, settings);

      expect(bytes, isNotEmpty);
    });

    test('X report PDF begins with %PDF header', () async {
      final bytes = await ReportPdfBuilder.build(report, settings);
      final header = String.fromCharCodes(bytes.take(4));

      expect(header, equals('%PDF'));
    });

    test('build() Z report returns non-empty bytes', () async {
      final bytes =
          await ReportPdfBuilder.build(report, settings, isZ: true);

      expect(bytes, isNotEmpty);
    });
  });
}
