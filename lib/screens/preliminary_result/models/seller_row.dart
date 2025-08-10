import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_row.freezed.dart';

@freezed
abstract class SellerRow with _$SellerRow implements TableRow {
  const factory SellerRow({
    required ArticleSeller seller,
    required WantsPrices pricesByProductId,
    required bool selected,
  }) = _SellerRow;
}
