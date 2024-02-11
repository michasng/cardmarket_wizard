import 'package:cardmarket_wizard/models/interfaces/article.dart';

abstract interface class Product {
  String get name;
  int? get totalArticleCount;
  int? get minPriceEuroCents;
  int? get priceTrendEuroCents;
  String? get rulesText;
  List<ArticleWithSeller> get articles;
}
