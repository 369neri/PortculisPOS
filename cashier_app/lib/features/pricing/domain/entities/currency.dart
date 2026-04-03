class Currency { // decimal digits for minor unit (e.g. 2 digits representing cents)

  Currency(this.code, {
      required this.name,
      required this.minorUnit,
      required this.numeric,
      this.symbol = '',
    }) : super();
  final String code; // ISO 4217 currency code (e.g. USD)
  final int numeric; // numeric code (e.g. USD = 840)
  final String symbol; // Abbreviation or symbol (e.g. USD = $)
  final String name; // currency name (e.g. US Dollar)
  final int minorUnit;
}
