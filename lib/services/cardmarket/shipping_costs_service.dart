import 'dart:convert';

import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/shipping_method.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

/// Based on info and API requests from https://help.cardmarket.com/en/ShippingCosts
class ShippingCostsService {
  static ShippingCostsService? _instance;

  ShippingCostsService._internal();

  factory ShippingCostsService.instance() {
    return _instance ??= ShippingCostsService._internal();
  }

  int _maxCardsInLetter(int maxletterWeightGram) {
    return switch (maxletterWeightGram) {
      20 => 4,
      50 => 17,
      100 => 40,
      // approximation without source from cardmarket,
      // verified that a more conservative factor of 0.2 is too low
      _ => (0.4 * maxletterWeightGram).ceil(),
    };
  }

  int estimateShippingCost({
    required int cardCount,
    required int valueEuroCents,
    required List<ShippingMethod> shippingMethods,
  }) {
    // Cardmarket info is inaccurate. Tracking is required at (not over) 25,00 €.
    // Theoretically also required for orders above 10 € from "new" sellers
    // or orders from sellers with > 2 % or "too many" lost orders.
    final mustUseTracking = valueEuroCents >= 2500;
    final viableShippingMethods = shippingMethods.where(
      (shippingMethod) =>
          valueEuroCents <= shippingMethod.maxValueEuroCents &&
          cardCount <= _maxCardsInLetter(shippingMethod.maxWeightGram) &&
          (!mustUseTracking || shippingMethod.isTracked),
    );
    assert(viableShippingMethods.isNotEmpty, 'No suited shipping method.');

    final cheapestShippingCost = viableShippingMethods
        .map((shippingMethod) => shippingMethod.priceEuroCents)
        .min;
    final trusteeServiceCost =
        mustUseTracking ? (valueEuroCents / 100).round() : 0;
    return cheapestShippingCost + trusteeServiceCost;
  }

  Future<List<ShippingMethod>> findShippingMethods({
    required Location fromCountry,
    required Location toCountry,
  }) async {
    // https://help.cardmarket.com/api/shippingCosts?locale=en&fromCountry=12&toCountry=7&preview=false
    final url = Uri.https(
      'help.cardmarket.com',
      'api/shippingCosts',
      <String, String>{
        'locale': 'en',
        'fromCountry': fromCountry.ordinal.toString(),
        'toCountry': toCountry.ordinal.toString(),
      },
    );
    final response = await http.get(url);
    // Workaround, because the API does not specify charset=utf-8 in the Content-Type header,
    // so response.body would default to latin1, which incorrectly parses euro sings "€" as "â¬".
    response.headers['content-type'] = 'application/json; charset=utf-8';
    final json = jsonDecode(response.body);
    return (json as List)
        .map(
          (jsonItem) =>
              ShippingMethod.fromApiResponse(jsonItem as Map<String, Object?>),
        )
        .toList();
  }
}
