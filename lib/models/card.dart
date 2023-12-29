import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';

class CardArticleSeller {
  final String name;
  final SellerRating? rating;
  final int? saleCount;
  final int? itemCount;
  final int? etaDays;
  final int? etaLocationDays;
  final Location location;
  final SellerType sellerType;
  final List<String>? warnings;

  const CardArticleSeller({
    required this.name,
    required this.rating,
    required this.saleCount,
    required this.itemCount,
    required this.etaDays,
    required this.etaLocationDays,
    required this.location,
    required this.sellerType,
    required this.warnings,
  });

  @override
  String toString() {
    return {
      'name': name,
      'rating': rating,
      'saleCount': saleCount,
      'itemCount': itemCount,
      'etaDays': etaDays,
      'etaLocationDays': etaLocationDays,
      'location': location,
      'sellerType': sellerType,
      'warnings': warnings,
    }.toString();
  }
}

class CardArticleProductInfo {
  final String expansion;
  final String rarity;
  final CardCondition condition;
  final CardLanguage language;
  final bool isReverseHolo;
  final bool isSigned;
  final bool isFirstEdition;
  final bool isAltered;
  final String? imageUrl;
  final String? comment;

  const CardArticleProductInfo({
    required this.expansion,
    required this.rarity,
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
      'expansion': expansion,
      'rarity': rarity,
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

class CardArticleOffer {
  final int priceEuroCents;
  final int quantity;

  const CardArticleOffer({
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

class CardArticle {
  final String? imageUrl;
  final CardArticleSeller seller;
  final CardArticleProductInfo productInfo;
  final CardArticleOffer offer;

  const CardArticle({
    required this.imageUrl,
    required this.seller,
    required this.productInfo,
    required this.offer,
  });

  @override
  String toString() {
    return {
      'imageUrl': imageUrl,
      'seller': seller,
      'productInfo': productInfo,
      'offer': offer,
    }.toString();
  }
}

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
