import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_config.freezed.dart';
part 'wizard_config.g.dart';

@freezed
class WizardConfig with _$WizardConfig {
  const WizardConfig._();

  @Assert('minSellersToLookup <= maxSellersToLookup')
  const factory WizardConfig({
    required Wants wants,
    @Default(6) int maxEtaDays,
    @Default(SellerRating.good) SellerRating minSellerRating,
    @Default(true) bool includeNewSellers,
    @Default(10) int minSellersToLookup,
    @Default(100) int maxSellersToLookup,
  }) = _WizardConfig;

  int get assumedNewSellerEtaDays =>
      includeNewSellers ? maxEtaDays : maxEtaDays + 1;
  SellerRating get assumedNewSellerRating =>
      includeNewSellers ? minSellerRating : SellerRating.bad;

  factory WizardConfig.fromJson(Map<String, Object?> json) =>
      _$WizardConfigFromJson(json);
}
