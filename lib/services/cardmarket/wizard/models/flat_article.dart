import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/enums/card_condition.dart';
import 'package:cardmarket_wizard/models/enums/card_language.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/single/single_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flat_article.freezed.dart';
part 'flat_article.g.dart';

@freezed
abstract class FlatArticle with _$FlatArticle {
  const FlatArticle._();

  const factory FlatArticle({
    required String id,
    required String sellerName,
    required String rarity,
    required CardCondition condition,
    required CardLanguage language,
    required bool isReverseHolo,
    required bool isSigned,
    required bool isFirstEdition,
    required bool isAltered,
    required String? imageUrl,
    required String? comment,
    required int priceEuroCents,
    required int quantity,
  }) = _FlatArticle;

  factory FlatArticle.fromCard(Card card, CardArticle cardArticle) {
    return FlatArticle(
      id: cardArticle.id,
      sellerName: cardArticle.seller.name,
      rarity: cardArticle.info.rarity,
      condition: cardArticle.info.condition,
      language: cardArticle.info.language,
      isReverseHolo: cardArticle.info.isReverseHolo,
      isSigned: cardArticle.info.isSigned,
      isFirstEdition: cardArticle.info.isFirstEdition,
      isAltered: cardArticle.info.isAltered,
      imageUrl: cardArticle.info.imageUrl ?? cardArticle.imageUrl,
      comment: cardArticle.info.comment,
      priceEuroCents: cardArticle.offer.priceEuroCents,
      quantity: cardArticle.offer.quantity,
    );
  }

  factory FlatArticle.fromSingle(Single single, SingleArticle singleArticle) {
    return FlatArticle(
      id: singleArticle.id,
      sellerName: singleArticle.seller.name,
      rarity: single.rarity,
      condition: singleArticle.info.condition,
      language: singleArticle.info.language,
      isReverseHolo: singleArticle.info.isReverseHolo,
      isSigned: singleArticle.info.isSigned,
      isFirstEdition: singleArticle.info.isFirstEdition,
      isAltered: singleArticle.info.isAltered,
      imageUrl: singleArticle.info.imageUrl ?? single.imageUrl,
      comment: singleArticle.info.comment,
      priceEuroCents: singleArticle.offer.priceEuroCents,
      quantity: singleArticle.offer.quantity,
    );
  }

  factory FlatArticle.fromSellerSingles(
    String sellerName,
    SellerSinglesArticle sellerSinglesArticle,
  ) {
    return FlatArticle(
      id: sellerSinglesArticle.id,
      sellerName: sellerName,
      rarity: sellerSinglesArticle.info.rarity,
      condition: sellerSinglesArticle.info.condition,
      language: sellerSinglesArticle.info.language,
      isReverseHolo: sellerSinglesArticle.info.isReverseHolo,
      isSigned: sellerSinglesArticle.info.isSigned,
      isFirstEdition: sellerSinglesArticle.info.isFirstEdition,
      isAltered: sellerSinglesArticle.info.isAltered,
      imageUrl:
          sellerSinglesArticle.info.imageUrl ?? sellerSinglesArticle.imageUrl,
      comment: sellerSinglesArticle.info.comment,
      priceEuroCents: sellerSinglesArticle.offer.priceEuroCents,
      quantity: sellerSinglesArticle.offer.quantity,
    );
  }

  factory FlatArticle.fromJson(Map<String, Object?> json) =>
      _$FlatArticleFromJson(json);
}
