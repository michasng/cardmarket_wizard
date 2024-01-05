extension Transform<TOrigin> on TOrigin {
  TTarget transform<TTarget>(TTarget Function(TOrigin) fn) {
    return fn(this);
  }
}

extension EmptyIterableAsNull<T extends Iterable> on T {
  T? get emptyAsNull {
    if (isEmpty) return null;
    return this;
  }
}

extension EmptyMapAsNull<T extends Map> on T {
  T? get emptyAsNull {
    if (isEmpty) return null;
    return this;
  }
}
