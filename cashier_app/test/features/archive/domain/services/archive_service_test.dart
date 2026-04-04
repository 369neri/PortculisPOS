import 'dart:io';
import 'dart:typed_data';

import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

late Directory _tmpDir;

ArchiveService _createService() => ArchiveService(
      baseDir: () async => _tmpDir,
    );

final _dummyBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // %PDF

Transaction _makeTx({
  int id = 1,
  String? invoiceNumber,
  DateTime? createdAt,
}) {
  final item = TradeItem(
    sku: 'TEST-001',
    label: 'Widget',
    unitPrice: Price.from(500),
  );
  final invoice = Invoice(items: [InvoiceItem(item: item)]).process();
  return Transaction(
    id: id,
    invoiceNumber: invoiceNumber,
    invoice: invoice,
    payments: [Payment(method: PaymentMethod.cash, amount: invoice.total)],
    status: TransactionStatus.completed,
    createdAt: createdAt ?? DateTime(2025, 7, 1, 14, 30, 45, 123),
  );
}

SalesReport _makeReport({DateTime? periodEnd}) => SalesReport(
      periodEnd: periodEnd ?? DateTime(2025, 7, 1, 23, 59, 59, 456),
      transactionCount: 5,
      voidedCount: 0,
      grossSales: Price.from(2500),
      taxEstimated: Price.from(250),
      paymentBreakdown: const {},
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    _tmpDir = Directory.systemTemp.createTempSync('archive_test_');
  });

  tearDown(() {
    if (_tmpDir.existsSync()) _tmpDir.deleteSync(recursive: true);
  });

  group('saveReceiptPdf', () {
    test('creates a file in the receipts directory', () async {
      final service = _createService();
      final tx = _makeTx(invoiceNumber: 'INV-001');

      final file = await service.saveReceiptPdf(_dummyBytes, tx);

      expect(file.existsSync(), isTrue);
      expect(file.path, contains('/receipts/'));
      expect(file.path, contains('receipt_INV-001_'));
      expect(file.readAsBytesSync(), equals(_dummyBytes));
    });

    test('uses transaction id when invoiceNumber is null', () async {
      final service = _createService();
      final tx = _makeTx(id: 42);

      final file = await service.saveReceiptPdf(_dummyBytes, tx);

      expect(file.path, contains('receipt_42_'));
    });

    test('two saves in same second produce different filenames', () async {
      final service = _createService();
      final tx1 = _makeTx(
        invoiceNumber: 'A',
        createdAt: DateTime(2025, 7, 1, 10, 0, 0, 100),
      );
      final tx2 = _makeTx(
        invoiceNumber: 'A',
        createdAt: DateTime(2025, 7, 1, 10, 0, 0, 200),
      );

      final f1 = await service.saveReceiptPdf(_dummyBytes, tx1);
      final f2 = await service.saveReceiptPdf(_dummyBytes, tx2);

      expect(f1.path, isNot(equals(f2.path)));
    });
  });

  group('saveReportPdf', () {
    test('creates X report file', () async {
      final service = _createService();
      final report = _makeReport();

      final file = await service.saveReportPdf(_dummyBytes, report);

      expect(file.existsSync(), isTrue);
      expect(file.path, contains('/reports/'));
      expect(file.path, contains('x_report_'));
    });

    test('creates Z report file with z prefix', () async {
      final service = _createService();
      final report = _makeReport();

      final file =
          await service.saveReportPdf(_dummyBytes, report, isZ: true);

      expect(file.path, contains('z_report_'));
    });
  });

  group('listByKind', () {
    test('returns empty list when no files saved', () async {
      final service = _createService();
      final result = await service.listByKind(ArchiveKind.receipt);

      expect(result, isEmpty);
    });

    test('returns saved receipt files sorted newest-first', () async {
      final service = _createService();
      final tx1 = _makeTx(
        invoiceNumber: 'OLD',
        createdAt: DateTime(2025, 1, 1, 0, 0, 0, 1),
      );
      final tx2 = _makeTx(
        invoiceNumber: 'NEW',
        createdAt: DateTime(2025, 7, 1, 0, 0, 0, 2),
      );

      await service.saveReceiptPdf(_dummyBytes, tx1);
      // Small delay so mtime differs.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await service.saveReceiptPdf(_dummyBytes, tx2);

      final list = await service.listByKind(ArchiveKind.receipt);

      expect(list, hasLength(2));
      expect(list.first.displayName, contains('NEW'));
      expect(list.last.displayName, contains('OLD'));
    });

    test('does not mix receipts and reports', () async {
      final service = _createService();
      await service.saveReceiptPdf(_dummyBytes, _makeTx());
      await service.saveReportPdf(_dummyBytes, _makeReport());

      final receipts = await service.listByKind(ArchiveKind.receipt);
      final reports = await service.listByKind(ArchiveKind.report);

      expect(receipts, hasLength(1));
      expect(reports, hasLength(1));
    });
  });

  group('delete', () {
    test('removes a specific archived file', () async {
      final service = _createService();
      await service.saveReceiptPdf(_dummyBytes, _makeTx());

      final before = await service.listByKind(ArchiveKind.receipt);
      expect(before, hasLength(1));

      await service.delete(before.first);

      final after = await service.listByKind(ArchiveKind.receipt);
      expect(after, isEmpty);
    });

    test('does not throw when file already missing', () async {
      final service = _createService();
      final phantom = ArchivedFile(
        path: '${_tmpDir.path}/nonexistent.pdf',
        displayName: 'ghost.pdf',
        savedAt: DateTime.now(),
        kind: ArchiveKind.receipt,
      );

      expect(() => service.delete(phantom), returnsNormally);
    });
  });

  group('clearAll', () {
    test('removes all files of a given kind', () async {
      final service = _createService();
      final tx1 = _makeTx(
        invoiceNumber: 'A',
        createdAt: DateTime(2025, 1, 1, 0, 0, 0, 1),
      );
      final tx2 = _makeTx(
        invoiceNumber: 'B',
        createdAt: DateTime(2025, 1, 1, 0, 0, 0, 2),
      );
      await service.saveReceiptPdf(_dummyBytes, tx1);
      await service.saveReceiptPdf(_dummyBytes, tx2);
      await service.saveReportPdf(_dummyBytes, _makeReport());

      await service.clearAll(ArchiveKind.receipt);

      final receipts = await service.listByKind(ArchiveKind.receipt);
      final reports = await service.listByKind(ArchiveKind.report);

      expect(receipts, isEmpty);
      expect(reports, hasLength(1), reason: 'reports should be untouched');
    });

    test('does not throw when directory does not exist', () async {
      final service = _createService();
      expect(
        () => service.clearAll(ArchiveKind.receipt),
        returnsNormally,
      );
    });
  });
}
