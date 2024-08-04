import 'package:async/async.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final/final_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:cardmarket_wizard/services/wizard_orchestrator.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardScreen extends StatefulWidget {
  final Wants wants;

  const WizardScreen({
    super.key,
    required this.wants,
  });

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  static final _logger = createLogger(WizardScreen);
  late CancelableOperation<WizardResult<WantsArticle>> _operation;

  @override
  void initState() {
    super.initState();

    final wizard = WizardOrchestrator.instance();
    _operation = CancelableOperation.fromFuture(
      wizard.run(OrchestratorConfig(wants: widget.wants)),
      onCancel: () => {_logger.warning('Wizard was cancelled early.')},
    );

    final navigator = Navigator.of(context);
    _operation.then((result) {
      navigator.go(FinalScreen(
        wants: widget.wants,
        result: result,
      ));
    });
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
            const Text(
              'You can watch the browser to see how information is collected.',
            ),
            const CircularProgressIndicator(),
            TextButton(
              onPressed: () {
                _operation.cancel();
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
