import 'package:equatable/equatable.dart';
import 'package:gtin_toolkit/gtin_toolkit.dart' as gtin_tool;

import 'validation_result.dart';
import 'item.dart';
import 'price.dart';

class TradeItem extends Equatable implements Item {
  // Item fields overrides
  @override
  final String sku;
  @override
  final String label;
  @override
  final Price unitPrice;

  // Fields specific to trade items
  final String? gtin; // GTIN: Global Trade Item Number (barcodes)

  const TradeItem({
    required this.sku, 
    required this.label,
    required this.unitPrice, 
    this.gtin
  }) : super();

  @override // equatable fields
  List<Object?> get props => [sku, label, unitPrice, gtin];

  @override
  ValidationResult validate() {
    // Validate the price field
    var price = unitPrice.validate();
    if (!price.isValid) return price;
    

    // Validate the GTIN field if present
    if (gtin != null) {
      var isValid = gtin_tool.parseAndValidate(gtin);
      if (isValid) return ValidationResult(true);
      return ValidationResult(
        false, 
        field: Field.gtin, 
        message: 'the GTIN is invalid');
    }
    return ValidationResult(true);
  }
}