import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/single/single_article_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_article.freezed.dart';
part 'single_article.g.dart';

@freezed
class SingleArticle with _$SingleArticle implements ArticleWithSeller {
  const SingleArticle._();

  const factory SingleArticle({
    required ArticleSeller seller,
    required SingleArticleInfo info,
    required ArticleOffer offer,
  }) = _SingleArticle;

  factory SingleArticle.fromJson(Map<String, Object?> json) =>
      _$SingleArticleFromJson(json);
}
