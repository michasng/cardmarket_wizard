import 'package:cardmarket_wizard/models/shipping_method.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:test/test.dart';

final rawShippingMethods = [
  {
    'name': 'Standardbrief',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 20,
    'stampPrice': '0,85 €',
    'price': '1,15 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Kompaktbrief',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 50,
    'stampPrice': '1,00 €',
    'price': '1,30 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Grossbrief',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 500,
    'stampPrice': '1,60 €',
    'price': '2,10 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Maxibrief',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 500,
    'stampPrice': '2,75 €',
    'price': '3,25 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Kompaktbrief + PRIO',
    'isTracked': true,
    'maxValue': '100,00 €',
    'maxWeight': 50,
    'stampPrice': '2,10 €',
    'price': '2,60 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Kompaktbrief + EINSCHREIBEN Übergabe',
    'isTracked': true,
    'maxValue': '100,00 €',
    'maxWeight': 50,
    'stampPrice': '3,65 €',
    'price': '4,15 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Grossbrief + PRIO',
    'isTracked': true,
    'maxValue': '100,00 €',
    'maxWeight': 500,
    'stampPrice': '2,70 €',
    'price': '3,20 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'Grossbrief + EINSCHREIBEN Übergabe',
    'isTracked': true,
    'maxValue': '100,00 €',
    'maxWeight': 500,
    'stampPrice': '4,25 €',
    'price': '4,75 €',
    'isLetter': true,
    'isVirtual': false,
  },
  {
    'name': 'DHL Päckchen S',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 2000,
    'stampPrice': '3,99 €',
    'price': '4,99 €',
    'isLetter': false,
    'isVirtual': false,
  },
  {
    'name': 'DHL Päckchen M',
    'isTracked': false,
    'maxValue': '25,00 €',
    'maxWeight': 2000,
    'stampPrice': '4,79 €',
    'price': '5,79 €',
    'isLetter': false,
    'isVirtual': false,
  },
];

void main() {
  final shippingMethods = [
    for (final method in rawShippingMethods)
      ShippingMethod.fromApiResponse(method),
  ];
  final shippingCostsService = ShippingCostsService.instance();

  group('estimateShippingCost', () {
    for (int cardCount in [1, 4]) {
      test('$cardCount cheap card(s)', () {
        final result = shippingCostsService.estimateShippingCost(
          cardCount: cardCount,
          valueEuroCents: 10 * cardCount,
          shippingMethods: shippingMethods,
        );
        expect(result, 115);
      });
    }

    for (int cardCount in [5, 17]) {
      test('$cardCount cheap cards', () {
        final result = shippingCostsService.estimateShippingCost(
          cardCount: cardCount,
          valueEuroCents: 10 * cardCount,
          shippingMethods: shippingMethods,
        );
        expect(result, 130);
      });
    }

    for (int cardCount in [18, 100, 200]) {
      test('$cardCount cheap cards', () {
        final result = shippingCostsService.estimateShippingCost(
          cardCount: cardCount,
          valueEuroCents: 10 * cardCount,
          shippingMethods: shippingMethods,
        );
        expect(result, 210);
      });
    }

    test('201 cheap cards', () {
      final result = shippingCostsService.estimateShippingCost(
        cardCount: 201,
        valueEuroCents: 2010,
        shippingMethods: shippingMethods,
      );
      expect(result, 499);
    });

    test('1 expensive card', () {
      final result = shippingCostsService.estimateShippingCost(
        cardCount: 1,
        valueEuroCents: 2500,
        shippingMethods: shippingMethods,
      );
      expect(result, 285);
    });

    test('2 expensive cards', () {
      final result = shippingCostsService.estimateShippingCost(
        cardCount: 2,
        valueEuroCents: 5000,
        shippingMethods: shippingMethods,
      );
      expect(result, 310);
    });
  });
}
