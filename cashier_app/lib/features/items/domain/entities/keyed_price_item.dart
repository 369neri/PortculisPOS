import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/entities/price.dart';

// A keyed-price item is manually keyed into the invoice on the keypad
// There is no sku code or label.
class KeyedPriceItem implements Item {
  final Price _unitPrice;

  KeyedPriceItem(this._unitPrice) : super();

  @override
  String? get sku => null;

  @override
  String? get label => null;

  @override
  Price get unitPrice => _unitPrice;

}