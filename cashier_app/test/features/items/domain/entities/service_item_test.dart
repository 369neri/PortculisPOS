
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/items/domain/entities/service_item.dart';
import 'package:test/test.dart';

main() {
  group('ServiceItem', () {
    test('Should create same hashcode for equatable service items', () {
      var item1 = ServiceItem(sku: 'sku', label: 'My Item', unitPrice: Price.from(256));
      var item2 = ServiceItem(sku: 'sku', label: 'My Item', unitPrice: Price.from(256));

      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}