import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:equatable/equatable.dart';

class ServiceItem extends Equatable implements Item {
  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  ServiceItem({
    required this.sku, 
    required this.label, 
    required this.unitPrice
  }) : super();

  @override
  List<Object?> get props => [sku, label, unitPrice];
}