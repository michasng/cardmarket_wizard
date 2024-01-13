import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article_info.dart';

class SellerSinglesArticle implements Article {
  final String? imageUrl;
  final String name;
  final String url;
  @override
  final SellerSingleArticleInfo info;
  @override
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
