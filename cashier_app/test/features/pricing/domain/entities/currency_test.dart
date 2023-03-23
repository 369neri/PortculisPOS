
import 'package:cashier_app/features/pricing/data/datasources/currencies.dart';
import 'package:cashier_app/features/pricing/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('Currencies', () {
    test('Should lookup by ISO 4217 currency code for USD', () async {
      Future<Currency?> currency = Currencies.lookupByCode('USD');
      var cur = await currency;

      expect(cur!.code, equals('USD'));
      expect(cur.name, equals('US Dollar'));
      expect(cur.numeric, equals(840));
      expect(cur.minorUnit, equals(2));
    });

    test('Should return null when the code does not exist', () async {
      Future<Currency?> currency = Currencies.lookupByCode('_ZZZ');

      expect(await currency, isNull);
    });
  });
}