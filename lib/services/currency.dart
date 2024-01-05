final _euroCentsPattern = RegExp(r'^(?<euros>\d+),(?<cents>\d\d)\s*€$');

int? tryParseEuroCents(String text) {
  final match = _euroCentsPattern.firstMatch(text);
  if (match == null) return null;
  final euros = int.parse(match.namedGroup('euros')!);
  final cents = int.parse(match.namedGroup('cents')!);
  return euros * 100 + cents;
}

int parseEuroCents(String text) {
  return tryParseEuroCents(text)!;
}

String formatPrice(int euroCents) {
  final euros = (euroCents ~/ 100).toString();
  final cents = (euroCents % 100).toString().padLeft(2, '0');
  return '$euros,$cents €';
}
