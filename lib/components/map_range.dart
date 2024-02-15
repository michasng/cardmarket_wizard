typedef Range<T extends num> = ({T lower, T upper});

extension MapRange<T extends num> on T {
  double mapRange({required Range<T> from, required Range<T> to}) {
    return (this - from.lower) *
            (to.upper - to.lower) /
            (from.upper - from.lower) +
        to.lower;
  }
}

extension MapIntRange on int {
  int mapIntRange({required Range<int> from, required Range<int> to}) {
    return (this - from.lower) *
            (to.upper - to.lower) ~/
            (from.upper - from.lower) +
        to.lower;
  }
}
