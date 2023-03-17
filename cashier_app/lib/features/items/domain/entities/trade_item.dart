import 'package:equatable/equatable.dart';
import 'package:gtin_toolkit/gtin_toolkit.dart' as gtinTool;
import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';

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

  TradeItem({
    required this.sku, 
    required this.label,
    required this.unitPrice, 
    this.gtin
  }) : super();

  @override
  List<Object?> get props => [sku, label, unitPrice, gtin];

  bool validateGtin() {
    return gtinTool.parseAndValidate(gtin);
  }
}