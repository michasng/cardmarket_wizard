import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_row.freezed.dart';

@freezed
class OfferRow with _$OfferRow implements TableRow {
  const factory OfferRow({
    required String sellerName,
    required String productId,
    required Article article,
    required int countToBuy,
  }) = _OfferRow;

  const OfferRow._();

  @override
  bool get selected => false;
}
