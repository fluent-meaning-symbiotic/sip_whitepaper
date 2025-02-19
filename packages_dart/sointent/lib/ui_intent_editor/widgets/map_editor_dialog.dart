import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

/// Dialog for editing map entries
class MapEditorDialog extends StatefulWidget {
  /// Creates a new instance of [MapEditorDialog]
  const MapEditorDialog({required this.title, super.key});

  /// The title of the dialog
  final String title;

  @override
  State<MapEditorDialog> createState() => _MapEditorDialogState();
}

class _MapEditorDialogState extends State<MapEditorDialog> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(widget.title, style: context.sectionTitleStyle),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColumnInputField(label: 'Key', controller: _keyController),
          const SizedBox(height: 16),
          ColumnInputField(
            label: 'Value',
            controller: _valueController,
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: context.labelStyle.copyWith(color: colorScheme.primary),
          ),
        ),
        FilledButton(
          onPressed:
              _keyController.text.isEmpty || _valueController.text.isEmpty
                  ? null
                  : () => Navigator.of(
                    context,
                  ).pop(MapEntry(_keyController.text, _valueController.text)),
          child: Text(
            'Add',
            style: context.labelStyle.copyWith(color: colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
