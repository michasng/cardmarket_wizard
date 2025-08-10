import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/models/flat_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_row.freezed.dart';

@freezed
abstract class OfferRow with _$OfferRow implements TableRow {
  const OfferRow._();

  const factory OfferRow({
    required String sellerName,
    required String productId,
    required FlatArticle article,
    required int countToBuy,
  }) = _OfferRow;

  @override
  bool get selected => false;
}
