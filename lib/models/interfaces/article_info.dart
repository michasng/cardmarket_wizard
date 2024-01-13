import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';

abstract interface class ArticleInfo {
  CardCondition get condition;
  CardLanguage get language;
  bool get isReverseHolo;
  bool get isSigned;
  bool get isFirstEdition;
  bool get isAltered;
  String? get imageUrl;
  String? get comment;
}
