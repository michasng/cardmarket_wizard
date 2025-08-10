import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_result_event.freezed.dart';

@freezed
abstract class WizardResultEvent
    with _$WizardResultEvent
    implements WizardEvent {
  const factory WizardResultEvent({
    required PriceOptimizerResult priceOptimizerResult,
  }) = _WizardResultEvent;
}
