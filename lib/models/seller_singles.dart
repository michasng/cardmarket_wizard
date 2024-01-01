import 'package:cardmarket_wizard/models/article_offer.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/pagination.dart';

class SellerSingleArticleInfo {
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

  const SellerSingleArticleInfo({
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

class SellerSinglesArticle {
  final String? imageUrl;
  final String name;
  final String url;
  final SellerSingleArticleInfo info;
  final ArticleOffer offer;

  const SellerSinglesArticle({
    required this.imageUrl,
    required this.name,
    required this.url,
    required this.info,
    required this.offer,
  });

  @override
  String toString() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'url': url,
      'info': info,
      'offer': offer,
    }.toString();
  }
}

class SellerSingles {
  final String name;
  final Location location;
  final int? etaDays;
  final Pagination pagination;
  final List<SellerSinglesArticle> articles;

  const SellerSingles({
    required this.name,
    required this.location,
    required this.etaDays,
    required this.pagination,
    required this.articles,
  });

  @override
  String toString() {
    return {
      'name': name,
      'location': location,
      'etaDays': etaDays,
      'pagination': pagination,
      'articles': articles,
    }.toString();
  }
}
