import 'package:flutter/widgets.dart';

import '../../../pricing/domain/entities/price.dart';
import 'item.dart';
import 'package:equatable/equatable.dart';

import 'validation_result.dart';

@immutable
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
    if (unitPrice.validate().isValid) return const ValidationResult(true);
    return const ValidationResult(
      false, 
      field: Field.price, 
      message: 'price cannot be negative');
  }
}