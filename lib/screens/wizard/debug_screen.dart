import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:flutter/material.dart';

class DebugScreen extends StatelessWidget {
  static final logger = createLogger(DebugScreen);

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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await WantsPage.fromCurrentPage();
                  final wants = await page.parse();
                  logger.info('PARSED WANTS: $wants');
                } catch (e) {
                  logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse wants'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await CardPage.fromCurrentPage();
                  final card = await page.parse();
                  logger.info('PARSED CARD: $card');
                } catch (e) {
                  logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse card'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await SinglePage.fromCurrentPage();
                  final single = await page.parse();
                  logger.info('PARSED SINGLE: $single');
                } catch (e) {
                  logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse single'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  final page = await SellerSinglesPage.fromCurrentPage();
                  final sellerSingles = await page.parse();
                  logger.info('PARSED SELLER SINGLES: $sellerSingles');
                } catch (e) {
                  logger.severe(e);
                  rethrow;
                }
              },
              child: const Text('Force parse seller singles'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.go(const LaunchScreen());
              },
              child: const Text('Restart wizard'),
            ),
          ],
        ),
      ),
    );
  }
}
