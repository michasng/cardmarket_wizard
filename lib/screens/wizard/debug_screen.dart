import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class DebugScreen extends StatelessWidget {
  static final _logger = createLogger(DebugScreen);

  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Debugging options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await WantsPage.fromCurrentPage();
                  final wants = await page.parse();
                  _logger.info('PARSED WANTS: $wants');
                } catch (e) {
                  _logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse wants'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await CardPage.fromCurrentPage();
                  final card = await page.parse();
                  _logger.info('PARSED CARD: $card');
                } catch (e) {
                  _logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse card'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await SinglePage.fromCurrentPage();
                  final single = await page.parse();
                  _logger.info('PARSED SINGLE: $single');
                } catch (e) {
                  _logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse single'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await SellerSinglesPage.fromCurrentPage();
                  final sellerSingles = await page.parse();
                  _logger.info('PARSED SELLER SINGLES: $sellerSingles');
                } catch (e) {
                  _logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse seller singles'),
            ),
            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.go(const LaunchScreen());
              },
              child: const Text('Restart wizard'),
            ),
          ].separated(const Gap()),
        ),
      ),
    );
  }
}
