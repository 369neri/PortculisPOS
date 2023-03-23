
import '../../../pricing/domain/entities/currency.dart';

class Currencies {
  static final Map<String, Currency?> _table = {
    'USD': Currency('USD', name: 'US Dollar', numeric: 840, minorUnit: 2),
  };

  static Future<Currency?> lookupByCode(String code) async {
    return Future(() => _table[code]);
  }
}