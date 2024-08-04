import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wants_article.freezed.dart';
part 'wants_article.g.dart';

@freezed
class WantsArticle with _$WantsArticle {
  const factory WantsArticle({
    required String id,
    required WantType wantType,
    required String? imageUrl,
    required int amount,
    required String name,
    required String url,
    required Set<String>? expansions,
    required Set<CardLanguage>? languages,
    required CardCondition minCondition,
    required bool? isReverseHolo,
    required bool? isSigned,
    required bool? isFirstEdition,
    required bool? isAltered,
    required int? buyPriceEuroCents,
    required bool? hasEmailAlert,
  }) = _WantsArticle;

  factory WantsArticle.fromJson(Map<String, Object?> json) =>
      _$WantsArticleFromJson(json);
}
