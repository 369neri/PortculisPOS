import 'price.dart';

import '../../../../core/validation_result.dart';

abstract class Item {
  String? get sku;
  String? get label;
  Price get unitPrice;

  ValidationResult validate();
}
