import 'dart:convert';

import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/shipping_method.dart';
import 'package:http/http.dart' as http;

/// Based on API requests from https://help.cardmarket.com/en/ShippingCosts
class ShippingCostsService {
  static ShippingCostsService? _instance;

  ShippingCostsService._internal();

  factory ShippingCostsService.instance() {
    return _instance ??= ShippingCostsService._internal();
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
          (jsonItem) => ShippingMethod.fromJson(jsonItem),
        )
        .toList();
  }
}
