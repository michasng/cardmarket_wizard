import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/single/single_article_info.dart';

class SingleArticle implements ArticleWithSeller {
  @override
  final ArticleSeller seller;
  @override
  final SingleArticleInfo info;
  @override
  final ArticleOffer offer;

  const SingleArticle({
    required this.seller,
    required this.info,
    required this.offer,
  });

  @override
  String toString() {
    return {
      'seller': seller,
      'info': info,
      'offer': offer,
    }.toString();
  }
}
