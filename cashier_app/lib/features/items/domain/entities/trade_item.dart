import 'package:gtin_toolkit/gtin_toolkit.dart' as gtinTool;
import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';

class TradeItem implements Item {
  // Item fields overridden
  final String _sku;
  final String _label;
  final Price _unitPrice;

  // Fields specific to trade items
  final String? gtin; // GTIN: Global Trade Item Number (barcodes)

  TradeItem(this._sku, this._label, this._unitPrice, {this.gtin}) : super();

  @override
  String get sku => _sku;

  @override
  String get label => _label;
  
  @override
  Price get unitPrice => _unitPrice;

  bool validateGtin() {
    return gtinTool.parseAndValidate(gtin);
  }
}