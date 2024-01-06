import 'package:async/async.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final_screen/final_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:cardmarket_wizard/services/wizard_orchestrator.dart';
import 'package:flutter/material.dart';

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
      wizard.run(widget.wants),
      onCancel: () => {_logger.warning('Wizard was cancelled early.')},
    );

    final navigator = Navigator.of(context);
    _operation.then((result) {
      navigator.go(FinalScreen(result: result));
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
            const SizedBox(height: 16),
            const Text(
              'You can watch the browser to see how information is collected.',
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _operation.cancel();
                final navigator = Navigator.of(context);
                navigator.go(const LaunchScreen());
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}