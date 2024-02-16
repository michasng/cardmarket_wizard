extension Clamp on Duration {
  /// Returns this [Duration] clamped to be in the range [lowerLimit]-[upperLimit].
  ///
  /// The arguments [lowerLimit] and [upperLimit] must form a valid range where
  /// `lowerLimit.compareTo(upperLimit) <= 0`.
  /// ```
  Duration clamp(Duration lowerLimit, Duration upperLimit) {
    return Duration(
      microseconds: inMicroseconds.clamp(
        lowerLimit.inMicroseconds,
        upperLimit.inMicroseconds,
      ),
    );
  }
}
