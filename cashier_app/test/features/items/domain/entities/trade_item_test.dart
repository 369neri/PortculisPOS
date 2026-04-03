import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:gtin_toolkit/generator.dart';
import 'package:test/test.dart';

void main() {
  group('TradeItem', () {
    test('should validate valid price as true', () {
      final item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(20),
      );
      
      expect(item.validate().isValid, equals(true));
    });
    
    test('should validate invalid price as false', () {
      final item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(-20),
      );
      
      expect(item.validate().isValid, equals(false));
    });

    test('should validate valid GTIN as true', () {
      final validGtin = generateGTIN(gtinLength: 12);

      final item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(120), 
        gtin: validGtin,
      );

      expect(item.validate().isValid, equals(true));
    });

    test('should validate invalid GTIN as false', () {
      final validGtin = generateGTIN(gtinLength: 12);
      final invalidGtin = validGtin.padRight(10).padRight(13, '1');
    
      final item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(120), 
        gtin: invalidGtin,
      );

      expect(item.validate().isValid, equals(false));
    });

    test('Should create same hashcode for two equatable items', () {
      final item1 = TradeItem(sku: 'sku', label: 'My item', unitPrice: Price.from(10));
      final item2 = TradeItem(sku: 'sku', label: 'My item', unitPrice: Price.from(10));

      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}
