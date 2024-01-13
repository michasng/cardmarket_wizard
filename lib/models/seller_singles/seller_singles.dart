import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/pagination.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';

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
