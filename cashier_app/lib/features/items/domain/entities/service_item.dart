import 'price.dart';
import 'item.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/validation_result.dart';

class ServiceItem extends Equatable implements Item {
  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  const ServiceItem({
    required this.sku, 
    required this.label, 
    required this.unitPrice
  }) : super();

  @override // equatable fields
  List<Object?> get props => [sku, label, unitPrice];

  @override
  ValidationResult validate() {
    if (unitPrice.validate().isValid) return ValidationResult(true);
    return ValidationResult(
      false, 
      field: Field.price, 
      message: 'price cannot be negative');
  }
}