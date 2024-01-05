extension GetOrPut<TKey, TValue> on Map<TKey, TValue> {
  TValue getOrPut(TKey key, TValue Function() createDefault) {
    final value = this[key];
    if (value != null) return value;

    final defaultValue = createDefault();
    this[key] = defaultValue;
    return defaultValue;
  }
}
