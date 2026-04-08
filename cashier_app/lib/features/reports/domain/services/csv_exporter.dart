import 'dart:io';

import 'package:cashier_app/core/extensions/format_helpers.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExporter {
  static Future<String> exportTransactions(
    List<Transaction> transactions,
  ) async {
    final rows = <List<dynamic>>[
      // Header
      [
        'ID',
        'Invoice #',
        'Date',
        'Status',
        'Items',
        'Subtotal',
        'Total Paid',
        'Change',
        'Payment Methods',
      ],
      // Data rows
      for (final tx in transactions)
        [
          tx.id ?? '',
          tx.invoiceNumber ?? '',
          tx.createdAt.toIso8601String(),
          tx.status.name,
          tx.invoice.items
              .map((i) => '${i.quantity}x ${i.item.label ?? i.item.sku ?? "Item"}')
              .join('; '),
          tx.invoice.total.toString(),
          tx.totalPaid.toString(),
          tx.changeDue.toString(),
          tx.payments.map((p) => p.method.name).toSet().join('+'),
        ],
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final stamp = Fmt.fileStamp(now);
    final path = '${dir.path}/transactions_$stamp.csv';
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }

  static Future<void> exportAndShare(List<Transaction> transactions) async {
    final path = await exportTransactions(transactions);
    await Share.shareXFiles([XFile(path)]);
  }
}
