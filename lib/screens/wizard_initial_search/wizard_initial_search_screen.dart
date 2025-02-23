import 'dart:async';

import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_product_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_result_event.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/preliminary_result_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardInitialSearchScreen extends StatefulWidget {
  final WizardConfig config;

  const WizardInitialSearchScreen({
    super.key,
    required this.config,
  });

  @override
  State<WizardInitialSearchScreen> createState() =>
      _WizardInitialSearchScreenState();
}

class _WizardInitialSearchScreenState extends State<WizardInitialSearchScreen> {
  static final _logger = createLogger(WizardInitialSearchScreen);
  late StreamSubscription<WizardEvent> _subscription;
  final List<WizardEvent> _events = [];

  @override
  void initState() {
    super.initState();
    final articlesByProductId = <String, List<ArticleWithSeller>>{};

    final navigator = Navigator.of(context);
    final wizard = WizardService.instance();
    final stream = wizard.runIntialSearch(widget.config);
    _subscription = stream.listen(
      (event) {
        setState(() {
          _events.add(event);
        });

        switch (event) {
          case WizardProductVisitedEvent():
            articlesByProductId[event.wantsArticle.id] = event.product.articles;
          case WizardResultEvent():
            navigator.go(
              PreliminaryResultScreen(
                config: widget.config,
                result: event.priceOptimizerResult,
                articlesByProductId: articlesByProductId,
              ),
            );
        }
      },
      onDone: () {
        _logger.info('Completed initial search.');
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        _logger.warning('Wizard was cancelled early.', error, stackTrace);
      },
    );
  }

  double get _productsLookupProgress {
    final wantedCount = widget.config.wants.articles.length;
    final productVisitedCount =
        _events.whereType<WizardProductVisitedEvent>().length;
    return productVisitedCount / wantedCount;
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
            const Text('Looking up wanted products.'),
            CircularProgressIndicator(value: _productsLookupProgress),
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
