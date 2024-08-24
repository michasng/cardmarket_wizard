final _euroCentsPattern = RegExp(r'^(?<euros>[\d\.]+),(?<cents>\d\d)\s*€$');

int? tryParseEuroCents(String text) {
  final match = _euroCentsPattern.firstMatch(text);
  if (match == null) return null;
  final euros = int.parse(match.namedGroup('euros')!.replaceAll('.', ''));
  final cents = int.parse(match.namedGroup('cents')!);
  return euros * 100 + cents;
}

int parseEuroCents(String text) {
  final result = tryParseEuroCents(text);
  if (result == null) {
    throw Exception('Unable to parse euro cents from text "$text".');
  }
  return result;
}

String formatPrice(int euroCents, {bool withEuroSymbol = true}) {
  final euros = (euroCents ~/ 100).toString();
  final cents = (euroCents % 100).toString().padLeft(2, '0');
  if (withEuroSymbol) return '$euros,$cents €';
  return '$euros,$cents';
}
