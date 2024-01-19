import 'package:cardmarket_wizard/services/currency.dart';
import 'package:test/test.dart';

void main() {
  group('tryParseEuroCents', () {
    test('parses supported price formats', () {
      expect(tryParseEuroCents('1,23 €'), 123);
      expect(tryParseEuroCents('1,23€'), 123);
      expect(tryParseEuroCents('1.234,56 €'), 123456);
      expect(tryParseEuroCents('6.630,00 €'), 663000);
    });

    test('does not parse unsupported price formats', () {
      expect(tryParseEuroCents('1 €'), null);
      expect(tryParseEuroCents('1€'), null);
    });

    test('does not parse invalid price formats', () {
      expect(tryParseEuroCents('1'), null);
      expect(tryParseEuroCents('1,23'), null);
      expect(tryParseEuroCents('a'), null);
    });
  });

  group('formatPrice', () {
    test('formats prices as expected', () {
      expect(formatPrice(0), '0,00 €');
      expect(formatPrice(1), '0,01 €');
      expect(formatPrice(10), '0,10 €');
      expect(formatPrice(100), '1,00 €');
      expect(formatPrice(99999), '999,99 €');
      expect(formatPrice(999999), '9999,99 €');
    });
  });
}
