import 'package:sointent/common_imports.dart';

/// {@template ordered_map}
/// Generic ordered collection maintaining insertion order
/// with key-based access
/// {@endtemplate}
class MutableOrderedMap<K, V> with Iterable<K> {
  final _items = <K, V>{};
  final _orderedKeys = <K>[];

  @override
  Iterator<K> get iterator => _orderedKeys.iterator;

  /// Returns items in insertion order
  List<V> get orderedValues {
    final values = <V>[];
    for (final key in _orderedKeys) {
      final value = _items[key];
      if (value == null) continue;
      values.add(value);
    }
    return values;
  }

  /// Adds item with validation
  @mustCallSuper
  void upsert(final K key, final V value) {
    _items[key] = value;
    _orderedKeys.add(key);
  }

  @mustCallSuper
  void remove(final K key) {
    _items.remove(key);
    _orderedKeys.remove(key);
  }

  @mustCallSuper
  void clear() {
    _items.clear();
    _orderedKeys.clear();
  }
}

/// {@template immutable_ordered_map}
/// Immutable ordered collection maintaining insertion order
/// with key-based access
/// {@endtemplate}
class ImmutableOrderedMap<K, V> with Iterable<K> {
  ImmutableOrderedMap([this._items = const {}, this._orderedKeys = const []]);
  Map<K, V> _items;
  List<K> _orderedKeys;

  @override
  Iterator<K> get iterator => _orderedKeys.iterator;

  List<K> get keys => _orderedKeys.unmodifiable;

  /// Returns items in insertion order
  List<V> get orderedValues {
    final values = <V>[];
    for (final key in _orderedKeys) {
      final value = _items[key];
      if (value == null) continue;
      values.add(value);
    }
    return values.unmodifiable;
  }

  V? operator [](final K key) => _items[key];
  void operator []=(final K key, final V value) => upsert(key, value);

  /// Assigns all items from a map
  void assignAll(final Map<K, V> map) {
    _items = map.unmodifiable;
    _orderedKeys = map.keys.toList().unmodifiable;
  }

  /// Adds item with validation
  @mustCallSuper
  void upsert(final K key, final V value) {
    final items = {..._items, key: value}.unmodifiable;
    final orderedKeys = [..._orderedKeys, key].unmodifiable;
    _items = items.unmodifiable;
    _orderedKeys = orderedKeys.unmodifiable;
  }

  @mustCallSuper
  void remove(final K key) {
    final items = {..._items}..remove(key);
    final orderedKeys = [..._orderedKeys]..remove(key);
    _items = items.unmodifiable;
    _orderedKeys = orderedKeys.unmodifiable;
  }

  @mustCallSuper
  void clear() {
    _items = <K, V>{}.unmodifiable;
    _orderedKeys = <K>[].unmodifiable;
  }
}
