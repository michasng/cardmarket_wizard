import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_offer.freezed.dart';
part 'article_offer.g.dart';

@freezed
class ArticleOffer with _$ArticleOffer {
  const factory ArticleOffer({
    required int priceEuroCents,
    required int quantity,
  }) = _ArticleOffer;

  factory ArticleOffer.fromJson(Map<String, Object?> json) =>
      _$ArticleOfferFromJson(json);
}
