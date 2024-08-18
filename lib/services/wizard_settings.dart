import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:micha_core/micha_core.dart';

class WizardSettings {
  static WizardSettings? _instance;

  factory WizardSettings.instance() {
    return _instance ??= throw Exception('Instance has not been initialized.');
  }

  final Location location;
  final RateLimiter<void> rateLimiter;

  WizardSettings({
    required this.location,
    required Duration requestInterval,
  }) : rateLimiter = RateLimiter(requestInterval) {
    _instance = this;
  }
}
