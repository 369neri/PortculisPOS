import 'dart:typed_data';

import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a PDF receipt from a completed [Transaction].
class ReceiptPdfBuilder {
  const ReceiptPdfBuilder._();

  /// Generates PDF bytes for a 80 mm thermal receipt.
  static Future<Uint8List> build(
    Transaction transaction,
    AppSettings settings, {
    double taxRate = 0.0,
  }) async {
    final doc = pw.Document();
    final sym = settings.currencySymbol;
    final label = transaction.invoiceNumber ?? '#${transaction.id ?? 0}';
    final subtotal = PriceCalculator.subtotal(transaction.invoice);
    final tax = PriceCalculator.tax(transaction.invoice, taxRate: taxRate);

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          200 * PdfPageFormat.mm,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                settings.businessName,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                _fmtDate(transaction.createdAt),
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Center(
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Divider(),
            ...transaction.invoice.items.map(
              (item) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '\u00d7${item.quantity}  ${item.item.label ?? ''}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Text(
                    '$sym${item.lineTotal}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('$sym$subtotal', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            if (taxRate > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tax ($taxRate%)', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('$sym$tax', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '$sym${PriceCalculator.grandTotal(transaction.invoice, taxRate: taxRate)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            ...transaction.payments.map(
              (p) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    p.method.name.toUpperCase(),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '$sym${p.amount}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            if (transaction.changeDue.value > BigInt.zero)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CHANGE', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    '$sym${transaction.changeDue}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                settings.receiptFooter,
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static String _fmtDate(DateTime dt) {
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$mo-$d $h:$mi';
  }
}
