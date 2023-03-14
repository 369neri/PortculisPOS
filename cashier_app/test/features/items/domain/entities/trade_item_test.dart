import 'package:cashier_app/features/items/domain/entities/price.dart';
import 'package:gtin_toolkit/generator.dart';
import 'package:test/test.dart';
import 'package:cashier_app/features/items/domain/entities/trade_item.dart';

main() {
  group('TradeItem', () {
    test('should throw FormatException on invalid price', () {
      expect(() => TradeItem('', '', Price.from(-20), null), throwsFormatException); 
    });
    
    test('should validate valid GTIN as true', () {
      String validGtin = generateGTIN(gtinLength: 12);

      var item = TradeItem('', '', Price.from(120), validGtin);

      expect(item.validateGtin(), equals(true));
    });

    test('should validate invalid GTIN as false', () {
      String validGtin = generateGTIN(gtinLength: 12);
      String invalidGtin = validGtin.padRight(10).padRight(13, '1');
    
      var item = TradeItem('', '', Price.from(120), invalidGtin);

      expect(item.validateGtin(), equals(false));
    });
  });
}