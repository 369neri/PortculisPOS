import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'validation_result.dart';
import 'item.dart';
import '../../../pricing/domain/entities/price.dart';

// A keyed-price item is manually keyed into the transaction on the keypad
// There is no sku code or label.
@immutable
class KeyedPriceItem extends Equatable implements Item {
  final Price _unitPrice;

  const KeyedPriceItem(this._unitPrice) : super();

  @override
  String? get sku => null;

  @override
  String? get label => null;

  @override
  Price get unitPrice => _unitPrice;
  
  @override // equatable fields
  List<Object?> get props => [unitPrice];

  @override
  ValidationResult validate() {
    return unitPrice.validate();
  }

}