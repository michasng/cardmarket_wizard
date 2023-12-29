import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/seller_type.dart';

class ArticleSeller {
  final String name;
  final SellerRating? rating;
  final int? saleCount;
  final int? itemCount;
  final int? etaDays;
  final int? etaLocationDays;
  final Location location;
  final SellerType sellerType;
  final List<String>? warnings;

  const ArticleSeller({
    required this.name,
    required this.rating,
    required this.saleCount,
    required this.itemCount,
    required this.etaDays,
    required this.etaLocationDays,
    required this.location,
    required this.sellerType,
    required this.warnings,
  });

  @override
  String toString() {
    return {
      'name': name,
      'rating': rating,
      'saleCount': saleCount,
      'itemCount': itemCount,
      'etaDays': etaDays,
      'etaLocationDays': etaLocationDays,
      'location': location,
      'sellerType': sellerType,
      'warnings': warnings,
    }.toString();
  }
}
