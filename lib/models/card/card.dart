import 'package:cardmarket_wizard/models/card/card_article.dart';

class Card {
  final String name;
  final int? totalArticleCount;
  final int? versionCount;
  final int? minPriceEuroCents;
  final int? priceTrendEuroCents;
  final String? rulesText;
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
