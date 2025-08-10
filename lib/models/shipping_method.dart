import 'package:cardmarket_wizard/services/currency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipping_method.freezed.dart';
part 'shipping_method.g.dart';

/// Average Delivery Time (days) is not included in this class,
/// because it is missing in API responses.
/// Cardmarket likely retrieves this information in another way.
@freezed
abstract class ShippingMethod with _$ShippingMethod {
  const factory ShippingMethod({
    required String name,
    required bool isTracked,
    required int maxValueEuroCents,
    required int maxWeightGram,

    /// Unlike other prices, which are always in Euro,
    /// the unit of [stampPrice] depends on the currency of the country.
    required String stampPrice,

    /// [priceEuroCents] is the currency adjusted [stampPrice] + a flat fee
    required int priceEuroCents,
    required bool isLetter,
    required bool isVirtual,
  }) = _ShippingMethod;

  factory ShippingMethod.fromJson(Map<String, Object?> json) =>
      _$ShippingMethodFromJson(json);

  factory ShippingMethod.fromApiResponse(Map<String, Object?> json) =>
      ShippingMethod(
        name: json['name'] as String,
        isTracked: json['isTracked'] as bool,
        maxValueEuroCents: parseEuroCents(json['maxValue'] as String),
        maxWeightGram: json['maxWeight'] as int,
        stampPrice: json['stampPrice'] as String,
        priceEuroCents: parseEuroCents(json['price'] as String),
        isLetter: json['isLetter'] as bool,
        isVirtual: json['isVirtual'] as bool,
      );
}
