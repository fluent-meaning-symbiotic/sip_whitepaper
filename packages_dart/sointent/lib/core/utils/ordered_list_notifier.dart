import 'package:sointent/common_imports.dart';
import 'package:sointent/core/utils/ordered_list.dart';

class OrderedListNotifier<V> extends ImmutableOrderedList<V>
    with ChangeNotifier {
  @override
  @mustCallSuper
  void add(final V value) {
    super.add(value);
    notifyListeners();
  }

  @override
  @mustCallSuper
  void remove(final V value) {
    super.remove(value);
    notifyListeners();
  }

  @override
  @mustCallSuper
  void clear() {
    super.clear();
    notifyListeners();
  }
}
