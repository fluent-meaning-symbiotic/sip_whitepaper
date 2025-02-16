import 'package:flutter/services.dart';
import 'package:sointent/common_imports.dart';

/// {@template yaml_editor}
/// A modular YAML editor widget with syntax highlighting and validation.
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
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_validateYaml);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateYaml() {
    final text = _controller.text;
    try {
      loadYaml(text);
      setState(() => _error = null);
      widget.onChanged(text);
    } catch (e) {
      final error = e.toString();
      setState(() => _error = error);
      widget.onValidationError?.call(error);
    }
  }

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          inputFormatters: [
            // Maintain proper indentation
            TabFormatter(),
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter intent YAML here...',
            errorText: _error,
            errorMaxLines: 3,
          ),
        ),
      ),
    ],
  );
}

/// Custom input formatter to handle tab key and maintain proper indentation
class TabFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    // Handle tab key
    if (newValue.text.endsWith('\t')) {
      final withoutTab = newValue.text.substring(0, newValue.text.length - 1);
      return TextEditingValue(
        text: '$withoutTab  ',
        selection: TextSelection.collapsed(offset: withoutTab.length + 2),
      );
    }
    return newValue;
  }
}
