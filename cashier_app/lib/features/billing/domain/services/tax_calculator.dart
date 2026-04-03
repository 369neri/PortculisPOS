import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

/// Stateless tax-calculation service.
///
/// Tax is computed on the invoice subtotal (exclusive — added on top).
/// Rate is expressed as a percentage: 0.0 = no tax, 10.0 = 10 %.
class TaxCalculator {
  const TaxCalculator._();

  /// Returns the tax amount for [invoice] at [rate] percent.
  ///
  /// Uses integer arithmetic to avoid floating-point drift:
  /// e.g. 10 % on 1000 subunits → 1000 × 1000 ÷ 10000 = 100 subunits.
  static Price calculate(Invoice invoice, double rate) {
    if (rate <= 0) return Price.from(0);
    final subtotal = invoice.total;
    final rateBasisPoints = BigInt.from((rate * 100).round());
    final taxValue = (subtotal.value * rateBasisPoints) ~/ BigInt.from(10000);
    return Price(taxValue);
  }
}
