import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wants.freezed.dart';

@freezed
abstract class Wants with _$Wants {
  const Wants._();

  const factory Wants({
    required String title,
    required String id,
    required List<WantsArticle> articles,
  }) = _Wants;

  WantsArticle findArticleByProductId(String productId) {
    return articles.firstWhere((article) => article.productId == productId);
  }
}
