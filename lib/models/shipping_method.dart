import 'package:cardmarket_wizard/services/currency.dart';

/// Average Delivery Time (days) is not included in this class,
/// because it is missing in API responses.
/// Cardmarket likely retrieves this information in another way.
class ShippingMethod {
  final String name;
  final bool isTracked;
  final int maxValueEuroCents;
  final int maxWeightGram;

  /// Unlike other prices, which are always in Euro,
  /// the unit of [stampPrice] depends on the currency of the country.
  final String stampPrice;
  final int priceEuroCents;
  final bool isLetter;
  final bool isVirtual;

  const ShippingMethod({
    required this.name,
    required this.isTracked,
    required this.maxValueEuroCents,
    required this.maxWeightGram,
    required this.stampPrice,
    required this.priceEuroCents,
    required this.isLetter,
    required this.isVirtual,
  });

  @override
  String toString() {
    return {
      'name': name,
      'isTracked': isTracked,
      'maxValueEuroCents': maxValueEuroCents,
      'maxWeightGram': maxWeightGram,
      'stampPrice': stampPrice,
      'priceEuroCents': priceEuroCents,
      'isLetter': isLetter,
      'isVirtual': isVirtual,
    }.toString();
  }

  factory ShippingMethod.fromJson(Map<String, Object?> json) => ShippingMethod(
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
