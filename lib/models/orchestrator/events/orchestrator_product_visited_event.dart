import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'orchestrator_product_visited_event.freezed.dart';
part 'orchestrator_product_visited_event.g.dart';

@freezed
class OrchestratorProductVisitedEvent
    with _$OrchestratorProductVisitedEvent
    implements OrchestratorEvent {
  const factory OrchestratorProductVisitedEvent({
    required WantsArticle wantsArticle,
    required Product product,
  }) = _OrchestratorProductVisitedEvent;

  factory OrchestratorProductVisitedEvent.fromJson(Map<String, Object?> json) =>
      _$OrchestratorProductVisitedEventFromJson(json);
}
