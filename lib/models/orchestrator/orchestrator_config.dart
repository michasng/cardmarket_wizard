import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'orchestrator_config.freezed.dart';
part 'orchestrator_config.g.dart';

@freezed
class OrchestratorConfig with _$OrchestratorConfig {
  @Assert('minSellersToLookup <= maxSellersToLookup')
  const factory OrchestratorConfig({
    required Wants wants,
    @Default(6) int maxEtaDays,
    @Default(SellerRating.good) SellerRating minSellerRating,
    @Default(true) bool includeNewSellers,
    @Default(10) int minSellersToLookup,
    @Default(100) int maxSellersToLookup,
  }) = _OrchestratorConfig;

  factory OrchestratorConfig.fromJson(Map<String, Object?> json) =>
      _$OrchestratorConfigFromJson(json);
}
