
extension PosBigInt on BigInt {
  static BigInt fromList<T>(List<T> list) {
    String s = '';
    for (var n in list) {
      s += n.toString();
    }

    int? price = int.tryParse(s);

    if (price != null) {
      return BigInt.from(price);
    } else {
      throw Exception('cannot convert buffer to BigInt');
    }
  }
}