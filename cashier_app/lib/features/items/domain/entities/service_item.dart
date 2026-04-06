part of 'item.dart';

@immutable
final class ServiceItem extends Item {
  const ServiceItem({
    required this.sku,
    required this.label,
    required this.unitPrice,
    this.category = '',
    this.isFavorite = false,
    this.imagePath,
  });

  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  @override
  final String category;

  @override
  int get stockQuantity => -1; // services never have stock

  @override
  final bool isFavorite;

  @override
  final String? imagePath;

  @override
  List<Object?> get props => [sku, label, unitPrice, category, isFavorite, imagePath];

  @override
  ValidationResult validate() {
    if (unitPrice.validate().isValid) return const ValidationResult(isValid: true);
    return const ValidationResult(
      isValid: false,
      field: Field.price,
      message: 'price cannot be negative',
    );
  }
}
