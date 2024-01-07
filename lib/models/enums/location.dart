enum Location {
  austria(1, 'Austria'),
  belgium(2, 'Belgium'),
  bulgaria(3, 'Bulgaria'),
  switzerland(4, 'Switzerland'),
  cyprus(5, 'Cyprus'),
  czechRepublic(6, 'Czech Republic'),
  germany(7, 'Germany'),
  denmark(8, 'Denmark'),
  estonia(9, 'Estonia'),
  spain(10, 'Spain'),
  finland(11, 'Finland'),
  france(12, 'France'),
  unitedKingdom(13, 'United Kingdom'),
  greece(14, 'Greece'),
  hungary(15, 'Hungary'),
  ireland(16, 'Ireland'),
  italy(17, 'Italy'),
  liechtenstein(18, 'Liechtenstein'),
  lithuania(19, 'Lithuania'),
  luxembourg(20, 'Luxembourg'),
  latvia(21, 'Latvia'),
  malta(22, 'Malta'),
  netherlands(23, 'Netherlands'),
  norway(24, 'Norway'),
  poland(25, 'Poland'),
  portugal(26, 'Portugal'),
  romania(27, 'Romania'),
  sweden(28, 'Sweden'),
  singapore(29, 'Singapore'),
  slovenia(30, 'Slovenia'),
  slovakia(31, 'Slovakia'),
  croatia(35, 'Croatia'),
  japan(36, 'Japan'),
  iceland(37, 'Iceland');

  final int ordinal;
  final String label;

  const Location(this.ordinal, this.label);

  factory Location.byLabel(String label) {
    return values.firstWhere((value) => value.label == label);
  }
}
