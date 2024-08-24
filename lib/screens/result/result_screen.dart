import 'package:cardmarket_wizard/components/wizard_result_view.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class ResultScreen extends StatelessWidget {
  final Wants wants;
  final PriceOptimizerResult result;

  const ResultScreen({
    super.key,
    required this.wants,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Wizard done',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                WizardResultView(
                  wants: wants,
                  result: result,
                ),
                FilledButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.go(const LoginScreen());
                  },
                  child: const Text('Try another wants list'),
                ),
              ].separated(const Gap()),
            ),
          ),
        ),
      ),
    );
  }
}
