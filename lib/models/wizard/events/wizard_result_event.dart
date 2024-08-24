import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_result_event.freezed.dart';
part 'wizard_result_event.g.dart';

@freezed
class WizardResultEvent with _$WizardResultEvent implements WizardEvent {
  const factory WizardResultEvent({
    required PriceOptimizerResult priceOptimizerResult,
  }) = _WizardResultEvent;

  factory WizardResultEvent.fromJson(Map<String, Object?> json) =>
      _$WizardResultEventFromJson(json);
}
