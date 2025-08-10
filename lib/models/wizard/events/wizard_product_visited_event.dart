import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_product_visited_event.freezed.dart';

@freezed
abstract class WizardProductVisitedEvent
    with _$WizardProductVisitedEvent
    implements WizardEvent {
  const factory WizardProductVisitedEvent({
    required WantsArticle wantsArticle,
    required Product product,
  }) = _WizardProductVisitedEvent;
}
