class ArticleOffer {
  final int priceEuroCents;
  final int quantity;

  const ArticleOffer({
    required this.priceEuroCents,
    required this.quantity,
  });

  @override
  String toString() {
    return {
      'priceEuroCents': priceEuroCents,
      'quantity': quantity,
    }.toString();
  }
}
