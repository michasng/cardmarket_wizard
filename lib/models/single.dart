import 'package:cardmarket_wizard/models/article_offer.dart';
import 'package:cardmarket_wizard/models/article_seller.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';

class SingleArticleProductInfo {
  final CardCondition condition;
  final CardLanguage language;
  final bool isReverseHolo;
  final bool isSigned;
  final bool isFirstEdition;
  final bool isAltered;
  final String? imageUrl;
  final String? comment;

  const SingleArticleProductInfo({
    required this.condition,
    required this.language,
    required this.isReverseHolo,
    required this.isSigned,
    required this.isFirstEdition,
    required this.isAltered,
    required this.imageUrl,
    required this.comment,
  });

  @override
  String toString() {
    return {
      'condition': condition,
      'language': language,
      'isReverseHolo': isReverseHolo,
      'isSigned': isSigned,
      'isFirstEdition': isFirstEdition,
      'isAltered': isAltered,
      'imageUrl': imageUrl,
      'comment': comment,
    }.toString();
  }
}

class SingleArticle {
  final ArticleSeller seller;
  final SingleArticleProductInfo productInfo;
  final ArticleOffer offer;

  const SingleArticle({
    required this.seller,
    required this.productInfo,
    required this.offer,
  });

  @override
  String toString() {
    return {
      'seller': seller,
      'productInfo': productInfo,
      'offer': offer,
    }.toString();
  }
}

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
