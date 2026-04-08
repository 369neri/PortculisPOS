import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/services/tax_calculator.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

class PriceCalculator {
  const PriceCalculator._();

  static Price subtotal(Invoice invoice) => invoice.total;

  static Price tax(Invoice invoice,
          {double taxRate = 0.0, bool taxInclusive = false}) =>
      TaxCalculator.calculate(invoice, taxRate, inclusive: taxInclusive);

  static Price grandTotal(Invoice invoice,
      {double taxRate = 0.0, bool taxInclusive = false}) {
    final sub = subtotal(invoice);
    if (taxInclusive) return sub; // prices already include tax
    final t = tax(invoice, taxRate: taxRate);
    return Price(sub.value + t.value);
  }
}
