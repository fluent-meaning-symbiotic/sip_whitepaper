import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/yaml_editor_controller.dart';

/// {@template yaml_editor}
/// A modular YAML editor widget with syntax highlighting and validation.
/// Provides features like:
/// - Syntax highlighting with Monokai theme
/// - Line numbers
/// - Auto-indentation
/// - YAML validation
/// - Format on demand
/// - Copy/paste with formatting
/// {@endtemplate}
class YamlEditor extends StatefulWidget {
  /// {@macro yaml_editor}
  const YamlEditor({
    required this.initialValue,
    required this.onChanged,
    this.onValidationError,
    super.key,
  });

  /// The initial YAML content
  final String initialValue;

  /// Callback when the YAML content changes
  final ValueChanged<String> onChanged;

  /// Callback when validation errors occur
  final ValueChanged<String>? onValidationError;

  @override
  State<YamlEditor> createState() => _YamlEditorState();
}

class _YamlEditorState extends State<YamlEditor> {
  late final YamlEditorController _controller;
  late final CodeController _codeController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(final YamlEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _updateContent(widget.initialValue);
    }
  }

  void _initializeControllers() {
    _controller = YamlEditorController(initialValue: widget.initialValue);
    _codeController = CodeController(
      text: widget.initialValue,
      language: yaml,
      patternMap: {
        // YAML specific patterns
        r'^[\s-]*[\w-]+:': const TextStyle(
          color: Color(0xFF66D9EF), // Key color (Monokai cyan)
          fontWeight: FontWeight.bold,
        ),
        r'#.*$': const TextStyle(
          color: Color(0xFF75715E), // Comment color (Monokai grey)
        ),
        'true|false|null': const TextStyle(
          color: Color(0xFFAE81FF), // Boolean/null color (Monokai purple)
        ),
        r'\d+': const TextStyle(
          color: Color(0xFFAE81FF), // Number color (Monokai purple)
        ),
        '".+"': const TextStyle(
          color: Color(0xFFE6DB74), // String color (Monokai yellow)
        ),
        "'.+'": const TextStyle(
          color: Color(0xFFE6DB74), // String color (Monokai yellow)
        ),
        r'^\s*-': const TextStyle(
          color: Color(0xFFF92672), // List item color (Monokai pink)
        ),
      },
    );

    _codeController.addListener(_handleTextChange);
  }

  void _updateContent(final String newContent) {
    if (_isUpdating) return;
    _isUpdating = true;

    // Update both controllers
    _controller.updateContent(newContent);
    _codeController.text = newContent;

    _isUpdating = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleTextChange() async {
    if (_isUpdating) return;
    _isUpdating = true;

    final text = _codeController.text;

    // Handle formatting in the controller
    if (text.contains('\n\n')) {
      final fixedText = text.replaceAll('\n\n', '\n');
      if (fixedText != text) {
        _codeController.text = fixedText;
        _isUpdating = false;
        return;
      }
    }

    // Handle indentation
    if (text.endsWith('\n')) {
      final lines = text.split('\n');
      if (lines.length > 1) {
        final previousLine = lines[lines.length - 2];
        final indent = previousLine.replaceAll(RegExp(r'[^\s].*$'), '');
        if (indent.isNotEmpty) {
          _codeController.text = '$text$indent';
          _isUpdating = false;
          return;
        }
      }
    }

    _controller.updateContent(text);

    if (_controller.error != null) {
      widget.onValidationError?.call(_controller.error!);
    } else {
      widget.onChanged(text);
    }

    _isUpdating = false;
  }

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Toolbar
      Material(
        color: const Color(0xFF272822), // Monokai background
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.format_align_left,
                  color: Color(0xFFF8F8F2),
                ),
                tooltip: 'Format YAML',
                onPressed: () {
                  _controller.format();
                  _codeController.text = _controller.content;
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.content_copy, color: Color(0xFFF8F8F2)),
                tooltip: 'Copy',
                onPressed: () async {
                  final text =
                      _codeController.selection.isValid
                          ? _controller.getFormattedSelection()
                          : _controller.content;
                  await Clipboard.setData(ClipboardData(text: text));
                },
              ),
            ],
          ),
        ),
      ),
      // Editor
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF272822), // Monokai background
            border: Border.all(
              color:
                  _controller.error != null
                      ? const Color(0xFFF92672) // Monokai red for errors
                      : const Color(0xFF49483E), // Monokai border
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.only(bottom: 8),
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.5,
              color: Color(0xFFF8F8F2), // Monokai text
            ),
            lineNumberStyle: const LineNumberStyle(
              width: 48,
              margin: 16,
              textStyle: TextStyle(
                color: Color(0xFF90908A), // Monokai line numbers
              ),
            ),
            background: const Color(0xFF272822), // Monokai background
          ),
        ),
      ),
      // Status Bar
      Material(
        color: const Color(0xFF272822), // Monokai background
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(
                'Position: ${_codeController.selection.baseOffset}',
                style: const TextStyle(
                  color: Color(0xFF90908A), // Monokai dimmed text
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (_controller.error != null)
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFF92672), // Monokai red for errors
                  size: 16,
                )
              else
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFA6E22E), // Monokai green for success
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Custom input formatter for YAML editing
class YamlInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int selectionOffset = newValue.selection.baseOffset;

    // Handle double newlines
    if (text.contains('\n\n')) {
      text = text.replaceAll('\n\n', '\n');
      selectionOffset -= text.length - newValue.text.length;
    }

    // Handle indentation after newlines
    if (text.endsWith('\n')) {
      final lines = text.split('\n');
      if (lines.length > 1) {
        final previousLine = lines[lines.length - 2];
        final indent = previousLine.replaceAll(RegExp(r'[^\s].*$'), '');
        if (indent.isNotEmpty) {
          text = '$text$indent';
          selectionOffset += indent.length;
        }
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
