import 'package:cardmarket_wizard/components/rate_limiter.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';

class WizardSettings {
  static WizardSettings? _instance;

  factory WizardSettings.instance() {
    return _instance ??= throw Exception('Instance has not been initialized.');
  }

  final Location location;
  final RateLimiter rateLimiter;

  WizardSettings({
    required this.location,
    required Duration requestInterval,
  }) : rateLimiter = RateLimiter(requestInterval) {
    _instance = this;
  }
}
