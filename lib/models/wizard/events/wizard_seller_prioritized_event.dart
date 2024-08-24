import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_seller_prioritized_event.freezed.dart';
part 'wizard_seller_prioritized_event.g.dart';

@freezed
class WizardSellerPrioritizedEvent
    with _$WizardSellerPrioritizedEvent
    implements WizardEvent {
  const factory WizardSellerPrioritizedEvent({
    required Set<String> sellerNamesToLookup,
  }) = _WizardSellerPrioritizedEvent;

  factory WizardSellerPrioritizedEvent.fromJson(
    Map<String, Object?> json,
  ) =>
      _$WizardSellerPrioritizedEventFromJson(json);
}
