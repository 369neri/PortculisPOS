import 'package:cashier_app/features/items/domain/entities/price.dart';

import '../../../../core/validation_result.dart';

abstract class Item {
  String? get sku;
  String? get label;
  Price get unitPrice;

  ValidationResult validate();
}
