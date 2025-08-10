import 'package:cardmarket_wizard/services/cardmarket/wizard/models/flat_article.dart';
import 'package:collection/collection.dart';

class ArticlesRepository {
  static ArticlesRepository? _instance;
  // rudamentary datastructure, optimized for one kind of access,
  // an indexed database would support different kinds of access.
  final Map<String, Map<String, List<FlatArticle>>>
      _articlesByProductIdBySellerName = {};

  ArticlesRepository._internal();

  factory ArticlesRepository.instance() {
    return _instance ??= ArticlesRepository._internal();
  }

  int get sellerCount => _articlesByProductIdBySellerName.length;
  Iterable<String> get sellerNames => _articlesByProductIdBySellerName.keys;
  int get articleCount => _articlesByProductIdBySellerName.values
      .map(
        (articlesByProductId) =>
            articlesByProductId.values.map((articles) => articles.length).sum,
      )
      .sum;

  void store({
    required String sellerName,
    required String wantsProductId,
    required FlatArticle article,
  }) {
    final articlesByProductId =
        _articlesByProductIdBySellerName.putIfAbsent(sellerName, () => {});
    final articles = articlesByProductId.putIfAbsent(wantsProductId, () => []);
    // A FlatArticle created from a seller's single might not be equal
    // to a previously stored FlatArticle created from a card or single.
    // Duplicate articles must not be stored.
    if (articles.where((a) => a.id == article.id).isEmpty) {
      articles.add(article);
    }
  }

  List<FlatArticle> retrieve({
    required String sellerName,
    required String wantsProductId,
  }) {
    return _articlesByProductIdBySellerName[sellerName]?[wantsProductId] ?? [];
  }

  Map<String, List<FlatArticle>> retrieveForSeller({
    required String sellerName,
  }) {
    return _articlesByProductIdBySellerName[sellerName] ?? {};
  }

  void clear() {
    _articlesByProductIdBySellerName.clear();
  }
}
