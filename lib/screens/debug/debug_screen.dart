import 'dart:convert';

import 'package:cardmarket_wizard/components/location_dropdown.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class DebugScreen extends StatefulWidget {
  static final _logger = createLogger(DebugScreen);

  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Location _fromCountry = Location.germany;
  Location _toCountry = Location.germany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Text(
                    'Debugging options',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'These actions log to the console.',
                  ),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final browserHolder = BrowserHolder.instance();
                        final page = await browserHolder.currentPage;
                        final cookies = await page.cookies();
                        final cookiesSerializable =
                            cookies.map((cookie) => cookie.toJson()).toList();
                        DebugScreen._logger.info(
                          'COOKIES: ${jsonEncode(cookiesSerializable)}',
                        );
                      } catch (e) {
                        DebugScreen._logger.severe(e);
                        rethrow;
                      }
                    },
                    child: const Text('Print cookies'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final page = await WantsPage.fromCurrentPage();
                        final wants = await page.parse();
                        DebugScreen._logger.info('PARSED WANTS: $wants');
                      } catch (e) {
                        DebugScreen._logger.severe(e);
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
                        DebugScreen._logger.info('PARSED CARD: $card');
                      } catch (e) {
                        DebugScreen._logger.severe(e);
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
                        DebugScreen._logger.info('PARSED SINGLE: $single');
                      } catch (e) {
                        DebugScreen._logger.severe(e);
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
                        DebugScreen._logger
                            .info('PARSED SELLER SINGLES: $sellerSingles');
                      } catch (e) {
                        DebugScreen._logger.severe(e);
                        rethrow;
                      }
                    },
                    child: const Text('Force parse seller singles'),
                  ),
                  Row(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: LocationDropdown(
                          labelText: 'from',
                          value: _fromCountry,
                          onChanged: (newValue) {
                            setState(() {
                              _fromCountry = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: LocationDropdown(
                          labelText: 'to',
                          value: _toCountry,
                          onChanged: (newValue) {
                            setState(() {
                              _toCountry = newValue;
                            });
                          },
                        ),
                      ),
                      FilledButton(
                        onPressed: () async {
                          try {
                            final shippingCostsService =
                                ShippingCostsService.instance();
                            final shippingCosts =
                                await shippingCostsService.findShippingMethods(
                              fromCountry: _fromCountry,
                              toCountry: _toCountry,
                            );
                            DebugScreen._logger.info(
                              'SHIPPING COSTS: $shippingCosts',
                            );
                          } catch (e) {
                            DebugScreen._logger.severe(e);
                            rethrow;
                          }
                        },
                        child: const Text('Determine shipping costs'),
                      ),
                    ],
                  ),
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
          ),
        ),
      ),
    );
  }
}
