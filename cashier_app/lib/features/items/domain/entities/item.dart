// ignore: empty_constructor_bodies
abstract class Item {
  final String? _sku = null;
  final String? _label = null;
  final double _unitPrice = 0.0;

  Item(String sku, String label, double price) : super();

  String? get sku => _sku;
  String? get label => _label;
  double get unitPrice => _unitPrice;
}
