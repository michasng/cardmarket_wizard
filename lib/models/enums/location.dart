enum Location {
  austria(1, 'Austria'),
  belgium(2, 'Belgium'),
  bulgaria(3, 'Bulgaria'),
  croatia(35, 'Croatia'),
  cyprus(5, 'Cyprus'),
  czechRepublic(6, 'Czech Republic'),
  denmark(8, 'Denmark'),
  estonia(9, 'Estonia'),
  finland(11, 'Finland'),
  france(12, 'France'),
  germany(7, 'Germany'),
  greece(14, 'Greece'),
  hungary(15, 'Hungary'),
  iceland(37, 'Iceland'),
  ireland(16, 'Ireland'),
  italy(17, 'Italy'),
  japan(36, 'Japan'),
  latvia(21, 'Latvia'),
  liechtenstein(18, 'Liechtenstein'),
  lithuania(19, 'Lithuania'),
  luxembourg(20, 'Luxembourg'),
  malta(22, 'Malta'),
  netherlands(23, 'Netherlands'),
  norway(24, 'Norway'),
  poland(25, 'Poland'),
  portugal(26, 'Portugal'),
  romania(27, 'Romania'),
  singapore(29, 'Singapore'),
  slovakia(31, 'Slovakia'),
  slovenia(30, 'Slovenia'),
  spain(10, 'Spain'),
  sweden(28, 'Sweden'),
  switzerland(4, 'Switzerland'),
  unitedKingdom(13, 'United Kingdom');

  final int ordinal;
  final String label;

  const Location(this.ordinal, this.label);

  factory Location.byLabel(String label) {
    return values.firstWhere((value) => value.label == label);
  }
}
