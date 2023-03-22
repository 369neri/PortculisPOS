import '../../../pricing/domain/entities/price.dart';
import 'validation_result.dart';

abstract class Item {
  String? get sku;
  String? get label;
  Price get unitPrice;

  ValidationResult validate();
}
