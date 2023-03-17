import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:gtin_toolkit/generator.dart';
import 'package:test/test.dart';
import 'package:cashier_app/features/items/domain/entities/trade_item.dart';

main() {
  group('TradeItem', () {
    test('should throw FormatException on invalid price', () {
      expect(() => TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(-20)
        ),
        throwsFormatException
      ); 
    });

    test('should validate valid GTIN as true', () {
      String validGtin = generateGTIN(gtinLength: 12);

      var item = TradeItem(
        sku: '', 
        label: '', 
        unitPrice: Price.from(120), 
        gtin: validGtin
      );

      expect(item.validateGtin(), equals(true));
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

      expect(item.validateGtin(), equals(false));
    });
  });
}