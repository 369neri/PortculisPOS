import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';

class TradeItem implements Item {
  // Item fields overridden
  final String _sku;
  final String _label;
  final Price _unitPrice;

  // Fields specific to products (trade items)
  final int? _gtin; // GTIN: Global Trade Item Number (barcodes)

  TradeItem(this._sku, this._gtin, this._label, this._unitPrice) : super();

  @override
  String get sku => _sku;

  @override
  String get label => _label;
  
  @override
  Price get unitPrice => _unitPrice;

  int? get gtin => _gtin;
}