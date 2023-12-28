enum CardCondition {
  mint(1, 'Mint', 'MT'),
  nearMint(2, 'Near Mint', 'NM'),
  excellent(3, 'Excellent', 'EX'),
  good(4, 'Good', 'GD'),
  lightPlayed(5, 'Light Played', 'LP'),
  played(6, 'Played', 'PL'),
  poor(7, 'Poor', 'PO');

  final int ordinal;
  final String label;
  final String abbreviation;

  const CardCondition(this.ordinal, this.label, this.abbreviation);

  factory CardCondition.byAbbreviation(String abbreviation) {
    return values.firstWhere((value) => value.abbreviation == abbreviation);
  }
}
