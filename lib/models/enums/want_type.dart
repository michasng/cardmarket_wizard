/// Each [card] or [single] is unique by [id].
/// A [single] is a specific product, i.e. a version of a card.
/// IDs of cards closely resemble the name of that card.
/// IDs of singles may also contain the [expansion] and [rarity] of a product, like "expansion/name-rarity",
/// so single IDs don't match their corresponding card IDs.
enum WantType {
  card('/Cards/'),
  single('/Products/Singles/');

  final String pathSegment;

  const WantType(this.pathSegment);

  factory WantType.byPath(String path) {
    return values.firstWhere((value) => path.contains(value.pathSegment));
  }
}
