import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:intl/intl.dart';

/// Extension on [Price] for locale-aware currency formatting.
extension PriceFormatting on Price {
  /// Formats this price with the given [symbol] (e.g. `$`, `€`).
  ///
  /// Uses fixed two-decimal output matching the price's [digits] property.
  String fmt(String symbol) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: digits,
    );
    // Convert subunits to a double for the formatter.
    final amount = value.toDouble() / _pow10(digits);
    return formatter.format(amount);
  }

  static double _pow10(int n) {
    var result = 1.0;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}

/// Common date/time formatters used across the app.
class Fmt {
  Fmt._();

  static final _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _receiptDate = DateFormat('dd MMM yyyy  HH:mm');
  static final _fileStamp = DateFormat("yyyyMMdd'_'HHmm");
  static final _fileStampMs = DateFormat("yyyyMMdd'_'HHmmss'_'SSS");

  /// `2026-04-06 14:30`
  static String dateTime(DateTime dt) => _dateTime.format(dt.toLocal());

  /// `06 Apr 2026  14:30`  (receipt header style)
  static String receiptDate(DateTime dt) => _receiptDate.format(dt.toLocal());

  /// `20260406_1430`  (file names)
  static String fileStamp(DateTime dt) => _fileStamp.format(dt.toLocal());

  /// `20260406_143022_001`  (file names with ms precision)
  static String fileStampMs(DateTime dt) => _fileStampMs.format(dt.toLocal());
}
