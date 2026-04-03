part of 'item.dart';

@immutable
final class ServiceItem extends Item {
  const ServiceItem({
    required this.sku,
    required this.label,
    required this.unitPrice,
  });

  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  @override
  List<Object?> get props => [sku, label, unitPrice];

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
