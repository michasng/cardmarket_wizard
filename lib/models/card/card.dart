import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

@freezed
class Card with _$Card implements Product {
  const Card._();

  const factory Card({
    required String name,
    required int? totalArticleCount,
    required int? versionCount,
    required int? minPriceEuroCents,
    required int? priceTrendEuroCents,
    required String? rulesText,
    required List<CardArticle> articles,
  }) = _Card;

  factory Card.fromJson(Map<String, Object?> json) => _$CardFromJson(json);
}
