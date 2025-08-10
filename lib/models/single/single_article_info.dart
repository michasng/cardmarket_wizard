import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/interfaces/article_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_article_info.freezed.dart';

@freezed
abstract class SingleArticleInfo
    with _$SingleArticleInfo
    implements ArticleInfo {
  const SingleArticleInfo._();

  const factory SingleArticleInfo({
    required CardCondition condition,
    required CardLanguage language,
    required bool isReverseHolo,
    required bool isSigned,
    required bool isFirstEdition,
    required bool isAltered,
    required String? imageUrl,
    required String? comment,
  }) = _SingleArticleInfo;
}
