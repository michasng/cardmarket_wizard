import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'orchestrator_seller_prioritized_event.freezed.dart';
part 'orchestrator_seller_prioritized_event.g.dart';

@freezed
class OrchestratorSellerPrioritizedEvent
    with _$OrchestratorSellerPrioritizedEvent
    implements OrchestratorEvent {
  const factory OrchestratorSellerPrioritizedEvent({
    required Set<String> sellerNamesToLookup,
  }) = _OrchestratorSellerPrioritizedEvent;

  factory OrchestratorSellerPrioritizedEvent.fromJson(
    Map<String, Object?> json,
  ) =>
      _$OrchestratorSellerPrioritizedEventFromJson(json);
}
