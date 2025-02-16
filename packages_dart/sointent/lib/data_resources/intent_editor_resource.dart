import 'package:sointent/common_imports.dart';

/// Resource for managing the currently edited intent state
class IntentEditorResource extends ChangeNotifier {
  /// Creates a new instance of [IntentEditorResource]
  IntentEditorResource();

  /// Singleton instance
  static late IntentEditorResource instance;

  SemanticIntentFile? _currentIntent;
  String? _pendingChanges;
  bool _isDirty = false;

  /// The currently edited intent
  SemanticIntentFile? get currentIntent => _currentIntent;

  /// The pending changes in YAML format
  String? get pendingChanges => _pendingChanges;

  /// Whether there are unsaved changes
  bool get isDirty => _isDirty;

  /// Updates the current state
  void updateState({
    final SemanticIntentFile? currentIntent,
    final String? pendingChanges,
    final bool? isDirty,
  }) {
    _currentIntent = currentIntent ?? _currentIntent;
    _pendingChanges = pendingChanges ?? _pendingChanges;
    _isDirty = isDirty ?? _isDirty;
    notifyListeners();
  }

  /// Resets the state
  void reset() {
    _currentIntent = null;
    _pendingChanges = null;
    _isDirty = false;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
