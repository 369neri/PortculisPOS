
import 'package:cashier_app/features/items/domain/entities/keyed_price_item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

main() {
  group('KeyedPriceItem', () {
    test('Should create same hashcode for equatable keyed-price items', () {
      var item1 = KeyedPriceItem(Price.from(156));
      var item2 = KeyedPriceItem(Price.from(156));

      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}