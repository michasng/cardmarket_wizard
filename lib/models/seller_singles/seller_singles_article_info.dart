import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/interfaces/article_info.dart';

class SellerSingleArticleInfo implements ArticleInfo {
  @override
  final CardCondition condition;
  @override
  final CardLanguage language;
  @override
  final bool isReverseHolo;
  @override
  final bool isSigned;
  @override
  final bool isFirstEdition;
  @override
  final bool isAltered;
  @override
  final String? imageUrl;
  @override
  final String? comment;

  final String expansion;

  final String rarity;

  const SellerSingleArticleInfo({
    required this.condition,
    required this.language,
    required this.isReverseHolo,
    required this.isSigned,
    required this.isFirstEdition,
    required this.isAltered,
    required this.imageUrl,
    required this.comment,
    required this.expansion,
    required this.rarity,
  });

  @override
  String toString() {
    return {
      'condition': condition,
      'language': language,
      'isReverseHolo': isReverseHolo,
      'isSigned': isSigned,
      'isFirstEdition': isFirstEdition,
      'isAltered': isAltered,
      'imageUrl': imageUrl,
      'comment': comment,
      'expansion': expansion,
      'rarity': rarity,
    }.toString();
  }
}
