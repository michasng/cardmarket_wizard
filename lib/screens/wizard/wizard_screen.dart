import 'dart:async';

import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_product_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_result_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_prioritized_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final/final_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/wizard_orchestrator.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardScreen extends StatefulWidget {
  final OrchestratorConfig config;

  const WizardScreen({
    super.key,
    required this.config,
  });

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  static final _logger = createLogger(WizardScreen);
  late StreamSubscription<OrchestratorEvent> _subscription;
  final List<OrchestratorEvent> _events = [];

  @override
  void initState() {
    super.initState();

    final navigator = Navigator.of(context);

    final orchestrator = WizardOrchestrator.instance();
    final stream = orchestrator.run(widget.config);
    _subscription = stream.listen(
      (event) {
        setState(() {
          _events.add(event);
        });

        if (event is OrchestratorResultEvent && !event.isPreliminary) {
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
        _events.whereType<OrchestratorProductVisitedEvent>().length;
    return productVisitedCount / wantedCount;
  }

  double get _sellersLookupProgress {
    final sellersToLookupCount = _events
        .whereType<OrchestratorSellerPrioritizedEvent>()
        .firstOrNull
        ?.sellerNamesToLookup
        .length;

    if (sellersToLookupCount == null) return 0;

    final sellerVisitedCount =
        _events.whereType<OrchestratorSellerVisitedEvent>().length;
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
