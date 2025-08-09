import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:collection/collection.dart';

class ArticlesRepository {
  static ArticlesRepository? _instance;
  // rudamentary datastructure, optimized for one kind of access,
  // an indexed database would support different kinds of access.
  final Map<String, Map<String, List<Article>>>
      _articlesByProductIdBySellerName = {};

  ArticlesRepository._internal();

  factory ArticlesRepository.instance() {
    return _instance ??= ArticlesRepository._internal();
  }

  int get sellerCount => _articlesByProductIdBySellerName.length;
  int get articleCount => _articlesByProductIdBySellerName.values
      .map(
        (articlesByProductId) =>
            articlesByProductId.values.map((articles) => articles.length).sum,
      )
      .sum;

  void store({
    required String sellerName,
    required String wantsProductId,
    required Article article,
  }) {
    final articlesByProductId =
        _articlesByProductIdBySellerName.putIfAbsent(sellerName, () => {});
    final articles = articlesByProductId.putIfAbsent(wantsProductId, () => []);
    if (articles.where((a) => a.id == article.id).isEmpty) {
    articles.add(article);
    }
  }

  List<Article> retrieve({
    required String sellerName,
    required String wantsProductId,
  }) {
    return _articlesByProductIdBySellerName[sellerName]?[wantsProductId] ?? [];
  }

  void clear() {
    _articlesByProductIdBySellerName.clear();
  }
}
