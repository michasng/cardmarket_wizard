import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/single/single_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single.freezed.dart';
part 'single.g.dart';

@freezed
class Single with _$Single implements Product {
  const Single._();

  const factory Single({
    required String name,
    required String extension,
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
  }) = _Single;

  factory Single.fromJson(Map<String, dynamic> json) => _$SingleFromJson(json);
}
