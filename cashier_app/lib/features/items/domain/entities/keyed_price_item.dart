part of 'item.dart';

// A keyed-price item is manually keyed into the transaction on the keypad.
// There is no sku code or label.
@immutable
final class KeyedPriceItem extends Item {
  const KeyedPriceItem(this._unitPrice);

  final Price _unitPrice;

  @override
  String? get sku => null;

  @override
  String? get label => null;

  @override
  Price get unitPrice => _unitPrice;

  @override
  List<Object?> get props => [unitPrice];

  @override
  ValidationResult validate() {
    return unitPrice.validate();
  }
}
