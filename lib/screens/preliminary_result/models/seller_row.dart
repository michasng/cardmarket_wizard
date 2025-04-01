import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_row.freezed.dart';

@freezed
class SellerRow with _$SellerRow {
  const factory SellerRow({
    required ArticleSeller seller,
    required WantsPrices pricesByProductId,
  }) = _SellerRow;
}
