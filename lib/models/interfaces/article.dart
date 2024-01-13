import 'package:cardmarket_wizard/models/interfaces/article_info.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';

abstract interface class Article {
  ArticleInfo get info;
  ArticleOffer get offer;
}

abstract interface class ArticleWithSeller extends Article {
  ArticleSeller get seller;
}
