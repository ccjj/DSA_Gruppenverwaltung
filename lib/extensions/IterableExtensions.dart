extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> indexedMap<T>(T Function(int index, E item) transform) sync* {
    int index = 0;
    for (E item in this) {
      yield transform(index, item);
      index++;
    }
  }
}
