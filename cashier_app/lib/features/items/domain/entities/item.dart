import 'package:flutter/widgets.dart';

import '../../../pricing/domain/entities/price.dart';
import 'validation_result.dart';

@immutable
abstract class Item {
  String? get sku;
  String? get label;
  Price get unitPrice;

  ValidationResult validate();
}
