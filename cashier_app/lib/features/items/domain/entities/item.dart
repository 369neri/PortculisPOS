// ignore: empty_constructor_bodies
abstract class Item {
  final String _sku;
  final String _label;
  final BigInt _unitPrice;

  Item(this._sku, this._label, this._unitPrice) : super();

  String get sku => _sku;
  String get label => _label;
  BigInt get unitPrice => _unitPrice;
}
