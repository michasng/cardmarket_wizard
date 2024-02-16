/// A range of [T], from lower to upper.
typedef Range<T extends num> = ({T lower, T upper});

extension MapRange<T extends num> on T {
  /// Maps this [T] from a starting range [from] to a target range [to].
  /// Unlike [mapIntRange], the result will be [double].
  /// This must not necessarily lie within either of those ranges.
  double mapRange({required Range<T> from, required Range<T> to}) {
    return (this - from.lower) *
            (to.upper - to.lower) /
            (from.upper - from.lower) +
        to.lower;
  }
}

extension MapIntRange on int {
  /// Maps this [int] from a starting range [from] to a target range [to].
  /// Unlike [mapRange], the result will remain [int], at a cost of accuracy depending on the use-case.
  /// This must not necessarily lie within either of those ranges.
  int mapIntRange({required Range<int> from, required Range<int> to}) {
    return (this - from.lower) *
            (to.upper - to.lower) ~/
            (from.upper - from.lower) +
        to.lower;
  }
}
