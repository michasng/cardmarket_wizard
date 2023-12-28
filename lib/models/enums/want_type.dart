/// Each [card] is unique by [id] (or [name]).
/// A [single] is a specific version of a card,
/// so it is expected to be unique by [id], [rarity] and [expansion].
/// Though the [rarity] is typically a part of the product ID,
/// so product IDs don't necessarily match their corresponding card IDs.
enum WantType {
  card('/Cards/'),
  single('/Products/Singles/');

  final String pathSegment;

  const WantType(this.pathSegment);

  factory WantType.byPath(String path) {
    return values.firstWhere((value) => path.contains(value.pathSegment));
  }
}
