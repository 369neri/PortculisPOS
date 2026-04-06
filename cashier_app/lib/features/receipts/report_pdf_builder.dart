import 'dart:io';
import 'dart:typed_data';

import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a PDF X/Z sales report from a [SalesReport].
class ReportPdfBuilder {
  const ReportPdfBuilder._();

  /// Generates A4 PDF bytes for the given report.
  ///
  /// Set [isZ] to `true` to label the report as a Z (end-of-day) report.
  static Future<Uint8List> build(
    SalesReport report,
    AppSettings settings, {
    bool isZ = false,
  }) async {
    final doc = pw.Document();
    final sym = settings.currencySymbol;
    final title = isZ ? 'Z Report — End of Day' : 'X Report';

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
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (logoImage != null) ...[
              pw.Center(
                child: pw.Image(logoImage, width: 80, height: 80),
              ),
              pw.SizedBox(height: 8),
            ],
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                settings.businessName,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                _periodLabel(report),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Divider(height: 24),
            _row('Transactions', report.transactionCount.toString()),
            _row('Voided', report.voidedCount.toString()),
            pw.Divider(height: 16),
            _row('Gross Sales', '$sym${report.grossSales}'),
            _row('Tax (est.)', '$sym${report.taxEstimated}'),
            _row(
              'Net Sales',
              '$sym${report.netSales}',
              bold: true,
            ),
            if (report.paymentBreakdown.isNotEmpty) ...[
              pw.Divider(height: 16),
              pw.Text(
                'By Payment Method',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 4),
              ...report.paymentBreakdown.entries.map(
                (e) => _row(
                  e.key.name.toUpperCase(),
                  '$sym${e.value}',
                ),
              ),
            ],
            pw.Divider(height: 24),
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

  static pw.Widget _row(String label, String value, {bool bold = false}) {
    final style = bold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle(fontSize: 11);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static String _periodLabel(SalesReport report) {
    final end = _fmtDate(report.periodEnd);
    if (report.periodStart != null) {
      return '${_fmtDate(report.periodStart!)} → $end';
    }
    return 'All time → $end';
  }

  static String _fmtDate(DateTime dt) {
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$mo-$d $h:$mi';
  }
}
