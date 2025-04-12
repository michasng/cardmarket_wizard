import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/single/single_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
sealed class Product with _$Product {
  const factory Product.card({
    required String name,
    required int? totalArticleCount,
    required int? versionCount,
    required int? minPriceEuroCents,
    required int? priceTrendEuroCents,
    required String? rulesText,
    required List<CardArticle> articles,
  }) = Card;

  const factory Product.single({
    required String name,
    required String expansion,
    required String? imageUrl,
    required String rarity,
    // card ID is only known for reprints. Those show a direct link to different card offers / versions.
    required String? cardId,
    required int versionCount,
    required int? totalArticleCount,
    required int? minPriceEuroCents,
    required int? priceTrendEuroCents,
    required int? thirtyDaysAveragePriceEuroCents,
    required int? sevenDaysAveragePriceEuroCents,
    required int? oneDayAveragePriceEuroCents,
    required String? rulesText,
    required List<SingleArticle> articles,
  }) = Single;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
