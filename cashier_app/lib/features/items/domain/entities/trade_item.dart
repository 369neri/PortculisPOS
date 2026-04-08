part of 'item.dart';

@immutable
final class TradeItem extends Item {
  const TradeItem({
    required this.sku,
    required this.label,
    required this.unitPrice,
    this.gtin,
    this.category = '',
    this.stockQuantity = -1,
    this.isFavorite = false,
    this.imagePath,
    this.itemTaxRate,
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
  final String category;

  /// Stock on hand. -1 means stock is not tracked for this item.
  @override
  final int stockQuantity;

  @override
  final bool isFavorite;

  @override
  final String? imagePath;

  @override
  final double? itemTaxRate;

  @override
  List<Object?> get props =>
      [sku, label, unitPrice, gtin, category, stockQuantity, isFavorite, imagePath, itemTaxRate];

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
