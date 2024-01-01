import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';

class WantsArticle {
  final String id;
  final WantType wantType;
  final String? imageUrl;
  final int amount;
  final String name;
  final String url;
  final Set<String>? expansions;
  final Set<CardLanguage>? languages;
  final CardCondition minCondition;
  final bool? isReverseHolo;
  final bool? isSigned;
  final bool? isFirstEdition;
  final bool? isAltered;
  final int? buyPriceEuroCents;
  final bool? hasEmailAlert;

  const WantsArticle({
    required this.id,
    required this.wantType,
    required this.imageUrl,
    required this.amount,
    required this.name,
    required this.url,
    required this.expansions,
    required this.languages,
    required this.minCondition,
    required this.isReverseHolo,
    required this.isSigned,
    required this.isFirstEdition,
    required this.isAltered,
    required this.buyPriceEuroCents,
    required this.hasEmailAlert,
  });

  @override
  String toString() {
    return {
      'id': id,
      'wantType': wantType.name,
      'imageUrl': imageUrl,
      'amount': amount,
      'name': name,
      'url': url,
      'expansions': expansions,
      'languages': languages,
      'minCondition': minCondition.label,
      'isReverseHolo': isReverseHolo,
      'isSigned': isSigned,
      'isFirstEdition': isFirstEdition,
      'isAltered': isAltered,
      'buyPriceEuroCents': buyPriceEuroCents,
      'hasEmailAlert': hasEmailAlert,
    }.toString();
  }
}

class Wants {
  String title;
  List<WantsArticle> articles;

  Wants({
    required this.title,
    required this.articles,
  });

  @override
  String toString() {
    return {
      'articles': articles,
    }.toString();
  }
}
