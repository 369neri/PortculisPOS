
import '../../../pricing/domain/entities/currency.dart';

class CurrenciesIso4217 {
    static Currency? lookupByCode(String code) {
    Map<String, Currency> table = {
      'USD': Currency(code, name: 'US Dollar', numeric: 840, minorUnit: 2),
    };

    return table[code];
  }
}