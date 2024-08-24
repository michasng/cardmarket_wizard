import 'package:cardmarket_wizard/components/map_range.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';

class SellerScoreService {
  static const Range<int> _normRange = (lower: 0, upper: 1);
  static SellerScoreService? _instance;

  SellerScoreService._internal();

  factory SellerScoreService.instance() {
    return _instance ??= SellerScoreService._internal();
  }

  Map<String, List<double>> determineSellerScores({
    required Map<String, List<ArticleWithSeller>> articlesByProductId,
  }) {
    final sellersScores = <String, List<double>>{};
    for (final articles in articlesByProductId.values) {
      final minPrice = articles.first.offer.priceEuroCents;
      final maxPrice = articles.last.offer.priceEuroCents;

      for (final article in articles) {
        if (!sellersScores.containsKey(article.seller.name)) {
          sellersScores[article.seller.name] =
              _calculateSellerScores(article.seller);
        }
        final score = minPrice == maxPrice
            ? 1.0
            : article.offer.priceEuroCents.mapRange(
                from: (lower: minPrice, upper: maxPrice),
                to: _normRange,
              );
        sellersScores[article.seller.name]!.add(score);
      }
    }
    return sellersScores;
  }

  List<double> _calculateSellerScores(ArticleSeller seller) {
    return [
      if (seller.etaDays != null)
        seller.etaDays!.mapRange(
          from: (lower: 7, upper: 2),
          to: _normRange,
        ),
      seller.etaLocationDays.mapRange(
        from: (lower: 7, upper: 2),
        to: _normRange,
      ),
      seller.itemCount.mapRange(
        from: (lower: 0, upper: 10000),
        to: _normRange,
      ),
    ];
  }
}
