
extension PosBigInt on String {
  BigInt toBigInt() {
    num? price = int.tryParse(this);

    if (price != null) {
      return BigInt.from(price);
    } else {
      throw Exception('cannot convert buffer string to BigInt');
    }
  }
}