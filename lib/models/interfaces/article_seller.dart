import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_seller.freezed.dart';
part 'article_seller.g.dart';

@freezed
class ArticleSeller with _$ArticleSeller {
  const factory ArticleSeller({
    required String name,
    // some sellers don't have enough sales to get a rating
    required SellerRating? rating,
    required int saleCount,
    required int itemCount,
    // some sellers don't have enough sales to get an ETA
    required int? etaDays,
    required int etaLocationDays,
    required Location location,
    required SellerType sellerType,
    required List<String>? warnings,
  }) = _ArticleSeller;

  factory ArticleSeller.fromJson(Map<String, Object?> json) =>
      _$ArticleSellerFromJson(json);
}
