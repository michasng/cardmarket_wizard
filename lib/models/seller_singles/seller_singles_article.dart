import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_offer.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_singles_article.freezed.dart';

@freezed
abstract class SellerSinglesArticle
    with _$SellerSinglesArticle
    implements Article {
  const SellerSinglesArticle._();

  const factory SellerSinglesArticle({
    required String id,
    required String productId,
    required String? imageUrl,
    required String name,
    required String url,
    required SellerSinglesArticleInfo info,
    required ArticleOffer offer,
  }) = _SellerSinglesArticle;
}
