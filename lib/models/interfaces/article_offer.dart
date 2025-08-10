import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_offer.freezed.dart';

@freezed
abstract class ArticleOffer with _$ArticleOffer {
  const factory ArticleOffer({
    required int priceEuroCents,
    required int quantity,
  }) = _ArticleOffer;
}
