import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  hierarchicalLoggingEnabled = true;
  final shoppingWizard = ShoppingWizard.instance();

  group('findBestOffers', () {
    test('finds best offers in a simple case', () {
      final wants = ['c1', 'c2', 'c3'];
      final sellersOffers = {
        's1': {
          'c1': [1],
          'c2': [2],
          'c3': [3],
        },
        's2': {
          'c1': [2],
          'c2': [1],
          'c3': [1],
        },
        's3': {
          'c2': [2],
          'c3': [1],
        },
      };

      final result = shoppingWizard.findBestOffers(
        wants: wants,
        sellersOffers: sellersOffers,
      );

      expect(
        result,
        const WizardResult(
          totalPrice: 3,
          sellerOffersToBuy: {
            's1': {
              'c1': [1]
            },
            's2': {
              'c2': [1],
              'c3': [1]
            },
          },
        ),
      );
    });

    test('finds best offers with duplicate wants', () {
      final wants = ['c1', 'c2', 'c2', 'c3', 'c3', 'c3', 'c3'];
      final sellersOffers = {
        's1': {
          'c1': [1],
          'c2': [2],
          'c3': [3],
        },
        's2': {
          'c1': [2],
          'c2': [1],
          'c3': [1],
        },
        's3': {
          'c2': [2],
          'c3': [1, 2],
        },
      };

      final result = shoppingWizard.findBestOffers(
        wants: wants,
        sellersOffers: sellersOffers,
      );

      expect(
        result,
        const WizardResult(
          totalPrice: 11,
          sellerOffersToBuy: {
            's1': {
              'c1': [1],
              'c2': [2],
              'c3': [3],
            },
            's2': {
              'c2': [1],
              'c3': [1],
            },
            's3': {
              'c3': [1, 2],
            },
          },
        ),
      );
    });

    test('finds best offers with missing offers', () {
      final wants = ['c1', 'c2', 'c3', 'c4'];
      final sellersOffers = {
        's1': {
          'c2': [1],
        },
      };

      final result = shoppingWizard.findBestOffers(
        wants: wants,
        sellersOffers: sellersOffers,
      );

      expect(
        result,
        const WizardResult(
          totalPrice: 1,
          sellerOffersToBuy: {
            's1': {
              'c2': [1],
            },
          },
          missingWants: ['c1', 'c3', 'c4'],
        ),
      );
    });

    test('finds best offers with constant shipping costs', () {
      final wants = ['c1', 'c2', 'c3'];
      final sellersOffers = {
        's1': {
          'c1': [1],
          'c2': [2],
          'c3': [3],
        },
        's2': {
          'c1': [2],
          'c2': [1],
          'c3': [1],
        },
      };

      final result = shoppingWizard.findBestOffers(
        wants: wants,
        sellersOffers: sellersOffers,
        calculateShippingCost: createCalculateShippingCost(2),
      );

      expect(
        result,
        const WizardResult(
          totalPrice: 6,
          sellerOffersToBuy: {
            's2': {
              'c1': [2],
              'c2': [1],
              'c3': [1],
            },
          },
        ),
      );
    });

    test('finds best offers with variable shipping costs', () {
      final wants = ['c1', 'c2', 'c3'];
      final sellersOffers = {
        's1': {
          'c1': [1],
          'c2': [2],
          'c3': [3],
        },
        's2': {
          'c1': [2],
          'c2': [1],
          'c3': [1],
        },
      };

      final result = shoppingWizard.findBestOffers(
        wants: wants,
        sellersOffers: sellersOffers,
        calculateShippingCost: ({
          required sellerName,
          required wantCount,
          required value,
        }) {
          return wantCount + 2;
        },
      );

      expect(
        result,
        const WizardResult(
          totalPrice: 9,
          sellerOffersToBuy: {
            's2': {
              'c1': [2],
              'c2': [1],
              'c3': [1],
            },
          },
        ),
      );
    });
  });
}
