import 'item.dart';

class Product implements Item {
  final String? _sku = null;
  final String? _label = null;
  final double _unitPrice = 0.0;

  @override
  String? get sku => _sku;

  @override
  String? get label => _label;
  
  @override
  double get unitPrice => _unitPrice;
}