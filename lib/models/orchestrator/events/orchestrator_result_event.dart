import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'orchestrator_result_event.freezed.dart';
part 'orchestrator_result_event.g.dart';

@freezed
class OrchestratorResultEvent
    with _$OrchestratorResultEvent
    implements OrchestratorEvent {
  const factory OrchestratorResultEvent({
    required PriceOptimizerResult priceOptimizerResult,
    required bool isPreliminary,
  }) = _OrchestratorResultEvent;

  factory OrchestratorResultEvent.fromJson(Map<String, Object?> json) =>
      _$OrchestratorResultEventFromJson(json);
}
