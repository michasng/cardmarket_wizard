import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/interfaces/article_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_singles_article_info.freezed.dart';
part 'seller_singles_article_info.g.dart';

@freezed
class SellerSinglesArticleInfo
    with _$SellerSinglesArticleInfo
    implements ArticleInfo {
  const SellerSinglesArticleInfo._();

  const factory SellerSinglesArticleInfo({
    required CardCondition condition,
    required CardLanguage language,
    required bool isReverseHolo,
    required bool isSigned,
    required bool isFirstEdition,
    required bool isAltered,
    required String? imageUrl,
    required String? comment,
    required String expansion,
    required String rarity,
  }) = _SellerSinglesArticleInfo;

  factory SellerSinglesArticleInfo.fromJson(Map<String, Object?> json) =>
      _$SellerSinglesArticleInfoFromJson(json);
}
