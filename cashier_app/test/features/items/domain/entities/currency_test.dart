
import 'package:cashier_app/features/pricing/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('Currency', () {
    test('Should lookup by ISO 4217 currency code for USD', () {
      Currency? currency = Currency.lookupByCode('USD');

      expect(currency!.code, equals('USD'));
      expect(currency.name, equals('US Dollar'));
      expect(currency.numeric, equals(840));
      expect(currency.minorUnit, equals(2));
    });
  });
}