import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';

class ProductItem implements Item {
  final String _sku;
  final String _label;
  final Price _unitPrice;

  ProductItem(this._sku, this._label, this._unitPrice) : super();

  @override
  String get sku => _sku;

  @override
  String get label => _label;
  
  @override
  Price get unitPrice => _unitPrice;

}