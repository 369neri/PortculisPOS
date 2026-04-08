import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

/// Stateless tax-calculation service.
///
/// Supports both tax-exclusive (added on top) and tax-inclusive
/// (back-calculated from prices that already contain tax) modes.
/// Rate is expressed as a percentage: 0.0 = no tax, 10.0 = 10 %.
///
/// When items carry their own [itemTaxRate], tax is computed per line
/// item using that rate (falling back to the global rate for items
/// without an override).
class TaxCalculator {
  const TaxCalculator._();

  /// Returns the tax amount for [invoice] at [rate] percent.
  ///
  /// If any invoice item has a non-null `itemTaxRate`, per-item
  /// calculation is used automatically.
  ///
  /// When [inclusive] is false (default), tax is added on top:
  ///   tax = subtotal × rate / 100
  ///
  /// When [inclusive] is true, prices already include tax and
  /// the tax portion is back-calculated:
  ///   tax = total × rate / (100 + rate)
  ///
  /// Uses integer arithmetic via basis-points to avoid floating-point drift.
  static Price calculate(Invoice invoice, double rate,
      {bool inclusive = false}) {
    final hasPerItem =
        invoice.items.any((i) => i.item.itemTaxRate != null);
    if (hasPerItem) {
      return _calculatePerItem(invoice, rate, inclusive: inclusive);
    }
    return _calculateFlat(invoice.total.value, rate, inclusive: inclusive);
  }

  /// Compute tax on a single amount at the given rate.
  static Price _calculateFlat(BigInt amount, double rate,
      {bool inclusive = false}) {
    if (rate <= 0) return Price.from(0);
    final rateBP = BigInt.from((rate * 100).round());
    if (inclusive) {
      final divisor = BigInt.from(10000) + rateBP;
      return Price((amount * rateBP) ~/ divisor);
    }
    return Price((amount * rateBP) ~/ BigInt.from(10000));
  }

  /// Sum tax computed per line item, each using its own rate (or global).
  static Price _calculatePerItem(Invoice invoice, double globalRate,
      {bool inclusive = false}) {
    var total = BigInt.zero;
    for (final li in invoice.items) {
      final rate = li.item.itemTaxRate ?? globalRate;
      final lineTax =
          _calculateFlat(li.lineTotal.value, rate, inclusive: inclusive);
      total += lineTax.value;
    }
    return Price(total);
  }
}
