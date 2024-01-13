import 'package:cardmarket_wizard/models/single/single_article.dart';

class Single {
  final String name;
  final String extension;
  final String? imageUrl;
  final String rarity;
  final String cardId;
  final int? versionCount;
  final int? totalArticleCount;
  final int? minPriceEuroCents;
  final int? priceTrendEuroCents;
  final int? thirtyDaysAveragePriceEuroCents;
  final int? sevenDaysAveragePriceEuroCents;
  final int? oneDayAveragePriceEuroCents;
  final String? rulesText;
  final List<SingleArticle> articles;

  const Single({
    required this.name,
    required this.extension,
    required this.imageUrl,
    required this.rarity,
    required this.cardId,
    required this.versionCount,
    required this.totalArticleCount,
    required this.minPriceEuroCents,
    required this.priceTrendEuroCents,
    required this.thirtyDaysAveragePriceEuroCents,
    required this.sevenDaysAveragePriceEuroCents,
    required this.oneDayAveragePriceEuroCents,
    required this.rulesText,
    required this.articles,
  });

  @override
  String toString() {
    return {
      'name': name,
      'extension': extension,
      'imageUrl': imageUrl,
      'rarity': rarity,
      'cardId': cardId,
      'versionCount': versionCount,
      'totalArticleCount': totalArticleCount,
      'minPriceEuroCents': minPriceEuroCents,
      'priceTrendEuroCents': priceTrendEuroCents,
      'thirtyDaysAveragePriceEuroCents': thirtyDaysAveragePriceEuroCents,
      'sevenDaysAveragePriceEuroCents': sevenDaysAveragePriceEuroCents,
      'oneDayAveragePriceEuroCents': oneDayAveragePriceEuroCents,
      'rulesText': rulesText,
      'articles': articles,
    }.toString();
  }
}
