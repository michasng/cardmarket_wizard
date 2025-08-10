import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/pagination.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_singles.freezed.dart';
part 'seller_singles.g.dart';

@freezed
abstract class SellerSingles with _$SellerSingles {
  const factory SellerSingles({
    required String name,
    required Location location,
    required int? etaDays,
    required Pagination pagination,
    required List<SellerSinglesArticle> articles,
  }) = _SellerSingles;

  factory SellerSingles.fromJson(Map<String, Object?> json) =>
      _$SellerSinglesFromJson(json);
}
