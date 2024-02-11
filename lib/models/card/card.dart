import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';

class Card implements Product {
  @override
  final String name;
  @override
  final int? totalArticleCount;
  final int? versionCount;
  @override
  final int? minPriceEuroCents;
  @override
  final int? priceTrendEuroCents;
  @override
  final String? rulesText;
  @override
  final List<CardArticle> articles;

  const Card({
    required this.name,
    required this.totalArticleCount,
    required this.versionCount,
    required this.minPriceEuroCents,
    required this.priceTrendEuroCents,
    required this.rulesText,
    required this.articles,
  });

  @override
  String toString() {
    return {
      'name': name,
      'totalArticleCount': totalArticleCount,
      'versionCount': versionCount,
      'minPriceEuroCents': minPriceEuroCents,
      'priceTrendEuroCents': priceTrendEuroCents,
      'rulesText': rulesText,
      'articles': articles,
    }.toString();
  }
}
