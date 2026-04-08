import 'dart:typed_data';

import 'package:cashier_app/core/extensions/format_helpers.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';

/// Generates ESC/POS byte commands for 58 mm / 80 mm thermal printers.
///
/// This is a pure-Dart implementation using standard ESC/POS command codes —
/// no external printing packages required.
class EscPosReceiptBuilder {
  const EscPosReceiptBuilder._();

  /// Standard 80 mm paper ≈ 48 characters per line at Font A.
  static const int _lineWidth = 48;

  static Future<Uint8List> build(
    Transaction transaction,
    AppSettings settings, {
    double taxRate = 0.0,
    bool taxInclusive = false,
  }) async {
    final buf = BytesBuilder(copy: false);
    final sym = settings.currencySymbol;
    final label = transaction.invoiceNumber ?? '#${transaction.id ?? 0}';
    final subtotal = PriceCalculator.subtotal(transaction.invoice);
    final tax = PriceCalculator.tax(transaction.invoice,
        taxRate: taxRate, taxInclusive: taxInclusive);
    final grandTotal = PriceCalculator.grandTotal(transaction.invoice,
        taxRate: taxRate, taxInclusive: taxInclusive);

    // Initialize printer.
    buf.add(_init);

    // ---- Header ----
    buf.add(_centerAlign);
    buf.add(_boldOn);
    buf.add(_doubleHeight);
    buf.add(_text(settings.businessName));
    buf.add(_normalSize);
    buf.add(_boldOff);
    buf.add(_text(_fmtDate(transaction.createdAt)));
    buf.add(_text(label));
    buf.add(_leftAlign);
    buf.add(_separator());

    // ---- Line items ----
    for (final item in transaction.invoice.items) {
      final desc = '\u00d7${item.quantity}  ${item.item.label ?? ''}';
      final price = item.lineTotal.fmt(sym);
      buf.add(_twoColumn(desc, price));
    }
    buf.add(_separator());

    // ---- Totals ----
    buf.add(_twoColumn('Subtotal', subtotal.fmt(sym)));
    if (taxRate > 0) {
      final taxLabel =
          taxInclusive ? 'Tax incl. ($taxRate%)' : 'Tax ($taxRate%)';
      buf.add(_twoColumn(taxLabel, tax.fmt(sym)));
    }
    buf.add(_boldOn);
    buf.add(_twoColumn('TOTAL', grandTotal.fmt(sym)));
    buf.add(_boldOff);
    buf.add(_feed(1));

    // ---- Payments ----
    for (final p in transaction.payments) {
      buf.add(_twoColumn(p.method.name.toUpperCase(), p.amount.fmt(sym)));
    }
    if (transaction.changeDue.value > BigInt.zero) {
      buf.add(_twoColumn('CHANGE', transaction.changeDue.fmt(sym)));
    }
    buf.add(_separator());

    // ---- Footer ----
    buf.add(_centerAlign);
    buf.add(_text(settings.receiptFooter));
    buf.add(_feed(4));

    // ---- Cut ----
    buf.add(_cut);

    return buf.toBytes();
  }

  // ---------------------------------------------------------------------------
  // ESC/POS command constants
  // ---------------------------------------------------------------------------

  /// ESC @ — Initialize printer.
  static final _init = Uint8List.fromList([0x1B, 0x40]);

  /// ESC a 0 — Left align.
  static final _leftAlign = Uint8List.fromList([0x1B, 0x61, 0x00]);

  /// ESC a 1 — Center align.
  static final _centerAlign = Uint8List.fromList([0x1B, 0x61, 0x01]);

  /// ESC E 1 — Bold on.
  static final _boldOn = Uint8List.fromList([0x1B, 0x45, 0x01]);

  /// ESC E 0 — Bold off.
  static final _boldOff = Uint8List.fromList([0x1B, 0x45, 0x00]);

  /// GS ! 0x11 — Double height + double width.
  static final _doubleHeight = Uint8List.fromList([0x1D, 0x21, 0x11]);

  /// GS ! 0x00 — Normal size.
  static final _normalSize = Uint8List.fromList([0x1D, 0x21, 0x00]);

  /// GS V 0 — Full cut.
  static final _cut = Uint8List.fromList([0x1D, 0x56, 0x00]);

  /// Encode text + LF.
  static Uint8List _text(String s) {
    // Truncate to line width to avoid wrapping surprises.
    final trimmed = s.length > _lineWidth ? s.substring(0, _lineWidth) : s;
    final bytes = BytesBuilder(copy: false)
      ..add(Uint8List.fromList(trimmed.codeUnits))
      ..addByte(0x0A); // LF
    return bytes.toBytes();
  }

  /// Two-column row: left-aligned label, right-aligned value.
  static Uint8List _twoColumn(String left, String right) {
    final gap = _lineWidth - left.length - right.length;
    final line =
        gap > 0 ? '$left${' ' * gap}$right' : '$left $right';
    return _text(line);
  }

  /// Dashed separator line.
  static Uint8List _separator() => _text('-' * _lineWidth);

  /// Feed n blank lines.
  static Uint8List _feed(int lines) =>
      Uint8List.fromList(List.filled(lines, 0x0A));

  static String _fmtDate(DateTime dt) => Fmt.dateTime(dt);
}
