import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'orchestrator_seller_visited_event.freezed.dart';
part 'orchestrator_seller_visited_event.g.dart';

@freezed
class OrchestratorSellerVisitedEvent
    with _$OrchestratorSellerVisitedEvent
    implements OrchestratorEvent {
  const factory OrchestratorSellerVisitedEvent({
    required WantsPrices sellerOffers,
  }) = _OrchestratorSellerVisitedEvent;

  factory OrchestratorSellerVisitedEvent.fromJson(Map<String, Object?> json) =>
      _$OrchestratorSellerVisitedEventFromJson(json);
}
