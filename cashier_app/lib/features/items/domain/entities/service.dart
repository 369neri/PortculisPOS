import 'item.dart';

class Service implements Item {
  final String _sku;
  final String _label;
  final BigInt _unitPrice;

  Service(this._sku, this._label, this._unitPrice) : super();

  @override
  String get sku => _sku;

  @override
  String get label => _label;
  
  @override
  BigInt get unitPrice => _unitPrice;
}