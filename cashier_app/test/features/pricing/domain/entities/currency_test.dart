
import 'package:cashier_app/features/pricing/data/datasources/currencies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currencies', () {
    test('Should lookup by ISO 4217 currency code for USD', () async {
      final currency = Currencies.lookupByCode('USD');
      final cur = await currency;

      expect(cur!.code, equals('USD'));
      expect(cur.name, equals('US Dollar'));
      expect(cur.numeric, equals(840));
      expect(cur.minorUnit, equals(2));
    });

    test('Should return null when the code does not exist', () async {
      final currency = Currencies.lookupByCode('_ZZZ');

      expect(await currency, isNull);
    });
  });
}
