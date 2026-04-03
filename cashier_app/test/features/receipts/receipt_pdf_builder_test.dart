import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/receipts/receipt_pdf_builder.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final item = TradeItem(
    sku: 'A1',
    label: 'Coffee',
    unitPrice: Price.from(350),
  );

  final tx = Transaction(
    id: 1,
    invoice: Invoice(items: [InvoiceItem(item: item, quantity: 2)]).process(),
    payments: [Payment(method: PaymentMethod.cash, amount: Price.from(700))],
    status: TransactionStatus.completed,
    createdAt: DateTime(2026, 1, 15, 9, 30),
  );

  const settings = AppSettings(
    businessName: 'Test Cafe',
    receiptFooter: 'Thank you!',
  );

  group('ReceiptPdfBuilder', () {
    test('build() returns non-empty bytes', () async {
      final bytes = await ReceiptPdfBuilder.build(tx, settings);

      expect(bytes, isNotEmpty);
    });

    test('PDF begins with %PDF header', () async {
      final bytes = await ReceiptPdfBuilder.build(tx, settings);
      final header = String.fromCharCodes(bytes.take(4));

      expect(header, equals('%PDF'));
    });

    test('build() with taxRate returns non-empty bytes', () async {
      final bytes =
          await ReceiptPdfBuilder.build(tx, settings, taxRate: 10);

      expect(bytes, isNotEmpty);
    });
  });
}
