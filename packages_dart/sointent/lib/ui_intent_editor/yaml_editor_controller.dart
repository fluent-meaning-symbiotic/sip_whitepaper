import 'package:sointent/common_imports.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Controller for managing YAML editing functionality
class YamlEditorController extends ChangeNotifier {
  /// Creates a new [YamlEditorController]
  YamlEditorController({required final String initialValue})
    : _editor = YamlEditor(initialValue);

  final YamlEditor _editor;
  final TextEditingController textController = TextEditingController();
  String? _error;

  /// Current error message, if any
  String? get error => _error;

  /// Current YAML content
  String get content => _editor.toString();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  /// Format the current YAML content
  void format() {
    try {
      final formatted = _editor.toString();
      textController.value = TextEditingValue(
        text: formatted,
        selection: textController.selection,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update YAML content
  void updateContent(final String newContent) {
    try {
      _editor.update([], loadYaml(newContent));
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get formatted selection
  String getFormattedSelection() {
    final selection = textController.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = textController.text.substring(
        selection.start,
        selection.end,
      );
      try {
        final yaml = loadYaml(selectedText);
        final editor = YamlEditor('');
        editor.update([], yaml);
        return editor.toString();
      } catch (_) {
        return selectedText;
      }
    }
    return '';
  }
}
