import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_seller_visited_event.freezed.dart';
part 'wizard_seller_visited_event.g.dart';

@freezed
class WizardSellerVisitedEvent
    with _$WizardSellerVisitedEvent
    implements WizardEvent {
  const factory WizardSellerVisitedEvent({
    required WantsPrices sellerOffers,
  }) = _WizardSellerVisitedEvent;

  factory WizardSellerVisitedEvent.fromJson(Map<String, Object?> json) =>
      _$WizardSellerVisitedEventFromJson(json);
}
