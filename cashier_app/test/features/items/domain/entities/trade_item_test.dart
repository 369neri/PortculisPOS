import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:gtin_toolkit/generator.dart';
import 'package:test/test.dart';
import 'package:cashier_app/features/items/domain/entities/trade_item.dart';

main() {
  group('TradeItem', () {
    test('should validate valid price as true', () {
      var item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(20)
      );
      
      expect(item.validate().isValid, equals(true));
    });
    
    test('should validate invalid price as false', () {
      var item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(-20)
      );
      
      expect(item.validate().isValid, equals(false));
    });

    test('should validate valid GTIN as true', () {
      String validGtin = generateGTIN(gtinLength: 12);

      var item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(120), 
        gtin: validGtin
      );

      expect(item.validate().isValid, equals(true));
    });

    test('should validate invalid GTIN as false', () {
      String validGtin = generateGTIN(gtinLength: 12);
      String invalidGtin = validGtin.padRight(10).padRight(13, '1');
    
      var item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(120), 
        gtin: invalidGtin
      );

      expect(item.validate().isValid, equals(false));
    });


  });
}