enum SellerRating implements Comparable<SellerRating> {
  outstanding('Outstanding', 3),
  veryGood('Very Good', 2),
  good('Good', 1),
  bad('Bad', 0);

  final String label;
  final int ordinal;

  const SellerRating(this.label, this.ordinal);

  @override
  int compareTo(SellerRating other) {
    return ordinal.compareTo(other.ordinal);
  }

  bool operator >(SellerRating other) => ordinal > other.ordinal;
  bool operator >=(SellerRating other) => ordinal >= other.ordinal;
  bool operator <(SellerRating other) => ordinal < other.ordinal;
  bool operator <=(SellerRating other) => ordinal <= other.ordinal;
}
