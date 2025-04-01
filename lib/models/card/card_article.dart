import 'package:cardmarket_wizard/models/card/card_article_info.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_article.freezed.dart';
part 'card_article.g.dart';

@freezed
class CardArticle with _$CardArticle implements ArticleWithSeller {
  const CardArticle._();

  const factory CardArticle({
    required String id,
    required ArticleSeller seller,
    required CardArticleInfo info,
    required ArticleOffer offer,
    required String? imageUrl,
  }) = _CardArticle;

  factory CardArticle.fromJson(Map<String, Object?> json) =>
      _$CardArticleFromJson(json);
}
