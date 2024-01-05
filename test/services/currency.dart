import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tryParseEuroCents', () {
    expect(tryParseEuroCents('1,23 €'), 123);
    expect(tryParseEuroCents('1,23€'), 123);
    expect(tryParseEuroCents('1,23'), 123);
    expect(tryParseEuroCents('1.23 €'), 123);
    expect(tryParseEuroCents('1.23€'), 123);
    expect(tryParseEuroCents('1.23'), 123);
    expect(tryParseEuroCents('1 €'), null);
    expect(tryParseEuroCents('1€'), null);
    expect(tryParseEuroCents('1'), null);
    expect(tryParseEuroCents('a'), null);
  });

  test('formatPrice', () {
    expect(formatPrice(0), '0,00 €');
    expect(formatPrice(1), '0,01 €');
    expect(formatPrice(10), '0,10 €');
    expect(formatPrice(100), '1,00 €');
    expect(formatPrice(99999), '999,99 €');
  });
}
