part of 'item.dart';

@immutable
final class TradeItem extends Item {
  const TradeItem({
    required this.sku,
    required this.label,
    required this.unitPrice,
    this.gtin,
  });

  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  // GTIN: Global Trade Item Number (barcodes)
  final String? gtin;

  @override
  List<Object?> get props => [sku, label, unitPrice, gtin];

  @override
  ValidationResult validate() {
    final price = unitPrice.validate();
    if (!price.isValid) return price;

    if (gtin != null) {
      final isValid = gtin_tool.parseAndValidate(gtin);
      if (isValid) return const ValidationResult(isValid: true);
      return const ValidationResult(
        isValid: false,
        field: Field.gtin,
        message: 'the GTIN is invalid',
      );
    }
    return const ValidationResult(isValid: true);
  }
}
