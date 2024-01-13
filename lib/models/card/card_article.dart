import 'package:cardmarket_wizard/models/card/card_article_info.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';

class CardArticle implements ArticleWithSeller {
  @override
  final ArticleSeller seller;
  @override
  final CardArticleInfo info;
  @override
  final ArticleOffer offer;
  final String? imageUrl;

  const CardArticle({
    required this.seller,
    required this.info,
    required this.offer,
    required this.imageUrl,
  });

  @override
  String toString() {
    return {
      'seller': seller,
      'info': info,
      'offer': offer,
      'imageUrl': imageUrl,
    }.toString();
  }
}
