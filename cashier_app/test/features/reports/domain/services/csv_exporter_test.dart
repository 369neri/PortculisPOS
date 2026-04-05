import 'dart:io';

import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/services/csv_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Transaction _makeTx({
  int id = 1,
  String? invoiceNumber,
  TransactionStatus status = TransactionStatus.completed,
}) {
  final item = TradeItem(sku: 'A', label: 'Apple', unitPrice: Price.from(100));
  final invoice = Invoice(items: [InvoiceItem(item: item)]);
  return Transaction(
    id: id,
    invoice: invoice,
    payments: [Payment(method: PaymentMethod.cash, amount: Price.from(100))],
    createdAt: DateTime(2025, 1, 15, 10, 30),
    invoiceNumber: invoiceNumber,
    status: status,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tmpDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tmpDir = Directory.systemTemp.createTempSync('csv_test_');

    // Mock path_provider to return our temp dir
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tmpDir.path;
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    tmpDir.deleteSync(recursive: true);
  });
  group('CsvExporter.exportTransactions', () {
    test('generates CSV with correct header for empty list', () async {
      final path = await CsvExporter.exportTransactions([]);

      // Read the file back
      final file = await _readCsvFile(path);
      expect(file, contains('ID'));
      expect(file, contains('Invoice #'));
      expect(file, contains('Payment Methods'));
      // Only header, no data rows
      final lines = file.trim().split('\n');
      expect(lines.length, 1);
    });

    test('generates correct data row for a transaction', () async {
      final tx = _makeTx(id: 42, invoiceNumber: 'INV-001');
      final path = await CsvExporter.exportTransactions([tx]);

      final file = await _readCsvFile(path);
      final lines = file.trim().split('\n');
      expect(lines.length, 2); // header + 1 data row
      expect(lines[1], contains('42'));
      expect(lines[1], contains('INV-001'));
      expect(lines[1], contains('completed'));
      expect(lines[1], contains('cash'));
    });

    test('handles multiple transactions', () async {
      final txs = [
        _makeTx(id: 1),
        _makeTx(id: 2, status: TransactionStatus.voided),
        _makeTx(id: 3, status: TransactionStatus.refunded),
      ];
      final path = await CsvExporter.exportTransactions(txs);

      final file = await _readCsvFile(path);
      final lines = file.trim().split('\n');
      // header + 3 data rows
      expect(lines.length, 4);
      expect(lines[2], contains('voided'));
      expect(lines[3], contains('refunded'));
    });
  });
}

Future<String> _readCsvFile(String path) async {
  final file = File(path);
  return file.readAsString();
}
