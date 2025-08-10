import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/interfaces/article_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_article_info.freezed.dart';

@freezed
abstract class CardArticleInfo with _$CardArticleInfo implements ArticleInfo {
  const CardArticleInfo._();

  const factory CardArticleInfo({
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
  }) = _CardArticleInfo;
}
