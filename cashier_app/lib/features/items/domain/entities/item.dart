import 'package:cashier_app/features/items/domain/entities/price.dart';

abstract class Item {
  String? get sku;
  String? get label;
  Price get unitPrice;
}
