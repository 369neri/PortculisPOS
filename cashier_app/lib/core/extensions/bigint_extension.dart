
extension PosBigInt on List<int> {
  BigInt toBigInt() {
    String s = '';
    for (var n in this) {
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