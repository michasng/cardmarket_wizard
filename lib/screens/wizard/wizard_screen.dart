import 'dart:async';

import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_product_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_result_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_seller_prioritized_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/final/final_screen.dart';
import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardScreen extends StatefulWidget {
  final WizardConfig config;

  const WizardScreen({
    super.key,
    required this.config,
  });

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  static final _logger = createLogger(WizardScreen);
  late StreamSubscription<WizardEvent> _subscription;
  final List<WizardEvent> _events = [];

  @override
  void initState() {
    super.initState();

    final navigator = Navigator.of(context);

    final wizard = WizardService.instance();
    final stream = wizard.run(widget.config);
    _subscription = stream.listen(
      (event) {
        setState(() {
          _events.add(event);
        });

        if (event is WizardResultEvent && !event.isPreliminary) {
          navigator.go(
            FinalScreen(
              wants: widget.config.wants,
              result: event.priceOptimizerResult,
            ),
          );
        }
      },
      onDone: () {
        _logger.info('DONE.');
      },
      onError: (error) {
        _logger.warning('Wizard was cancelled early.');
      },
    );
  }

  double get _productsLookupProgress {
    final wantedCount = widget.config.wants.articles.length;
    final productVisitedCount =
        _events.whereType<WizardProductVisitedEvent>().length;
    return productVisitedCount / wantedCount;
  }

  double get _sellersLookupProgress {
    final sellersToLookupCount = _events
        .whereType<WizardSellerPrioritizedEvent>()
        .firstOrNull
        ?.sellerNamesToLookup
        .length;

    if (sellersToLookupCount == null) return 0;

    final sellerVisitedCount =
        _events.whereType<WizardSellerVisitedEvent>().length;
    return sellerVisitedCount / sellersToLookupCount;
  }

  @override
  Widget build(BuildContext context) {
    final productsLookupProgress = _productsLookupProgress;
    final sellersLookupProgress = _sellersLookupProgress;

    final stateLabel = productsLookupProgress < 1
        ? 'Looking up wanted products.'
        : 'Looking up sellers to reduce cost.';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wizard in progress. Please wait.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(stateLabel),
            CircularProgressIndicator(
              value: sellersLookupProgress == 0
                  ? productsLookupProgress
                  : sellersLookupProgress,
            ),
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
