import 'dart:async';

import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_result_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:cardmarket_wizard/screens/result/result_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardOptimizeSearchScreen extends StatefulWidget {
  final WizardConfig config;
  final Set<String> sellerNamesToLookup;

  const WizardOptimizeSearchScreen({
    super.key,
    required this.config,
    required this.sellerNamesToLookup,
  });

  @override
  State<WizardOptimizeSearchScreen> createState() =>
      _WizardOptimizeSearchScreenState();
}

class _WizardOptimizeSearchScreenState
    extends State<WizardOptimizeSearchScreen> {
  static final _logger = createLogger(WizardOptimizeSearchScreen);
  late StreamSubscription<WizardEvent> _subscription;
  final List<WizardEvent> _events = [];

  @override
  void initState() {
    super.initState();

    final navigator = Navigator.of(context);
    final wizard = WizardService.instance();
    final stream = wizard.runToOptimize(
      widget.config,
      sellerNamesToLookup: widget.sellerNamesToLookup,
    );
    _subscription = stream.listen(
      (event) {
        setState(() {
          _events.add(event);
        });

        if (event is WizardResultEvent) {
          navigator.go(
            ResultScreen(
              wants: widget.config.wants,
              result: event.priceOptimizerResult,
            ),
          );
        }
      },
      onDone: () {
        _logger.info('Completed search to optimize.');
      },
      onError: (error) {
        _logger.warning('Wizard was cancelled early.');
      },
    );
  }

  double get _sellersLookupProgress {
    if (widget.sellerNamesToLookup.isEmpty) return 1;

    final sellerVisitedCount =
        _events.whereType<WizardSellerVisitedEvent>().length;
    return sellerVisitedCount / widget.sellerNamesToLookup.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wizard in progress. Please wait.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text('Looking up sellers to reduce cost.'),
            CircularProgressIndicator(value: _sellersLookupProgress),
            const Text(
              'You can watch the browser to see how information is collected.',
            ),
            TextButton(
              onPressed: () {
                _subscription.cancel();
                final navigator = Navigator.of(context);
                navigator.go(const LaunchScreen());
              },
              child: const Text('Cancel'),
            ),
          ].separated(const Gap()),
        ),
      ),
    );
  }
}
