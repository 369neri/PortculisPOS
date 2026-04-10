import 'dart:io';
import 'dart:typed_data';

import 'package:cashier_app/core/extensions/format_helpers.dart';
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
    bool taxInclusive = false,
  }) async {
    final doc = pw.Document();
    final sym = settings.currencySymbol;
    final label = transaction.invoiceNumber ?? '#${transaction.id ?? 0}';
    final subtotal = PriceCalculator.subtotal(transaction.invoice);
    final tax = PriceCalculator.tax(transaction.invoice,
        taxRate: taxRate, taxInclusive: taxInclusive,);

    // Attempt to load logo if configured.
    pw.MemoryImage? logoImage;
    if (settings.logoPath != null && settings.logoPath!.isNotEmpty) {
      final logoFile = File(settings.logoPath!);
      if (logoFile.existsSync()) {
        logoImage = pw.MemoryImage(logoFile.readAsBytesSync());
      }
    }

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
            if (logoImage != null) ...[
              pw.Center(
                child: pw.Image(logoImage, width: 60, height: 60),
              ),
              pw.SizedBox(height: 4),
            ],
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
                    item.lineTotal.fmt(sym),
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
                pw.Text(subtotal.fmt(sym), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            if (taxRate > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    taxInclusive ? 'Tax incl. ($taxRate%)' : 'Tax ($taxRate%)',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(tax.fmt(sym), style: const pw.TextStyle(fontSize: 10)),
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
                  PriceCalculator.grandTotal(transaction.invoice,
                          taxRate: taxRate, taxInclusive: taxInclusive,)
                      .fmt(sym),
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
                    p.amount.fmt(sym),
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
                    transaction.changeDue.fmt(sym),
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
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: '$label|${PriceCalculator.grandTotal(transaction.invoice, taxRate: taxRate, taxInclusive: taxInclusive).fmt(sym)}|${_fmtDate(transaction.createdAt)}',
                width: 60,
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static String _fmtDate(DateTime dt) => Fmt.dateTime(dt);
}
