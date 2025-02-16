import 'package:sointent/common_imports.dart';

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
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _keyController,
          decoration: const InputDecoration(
            labelText: 'Key',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Value',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed:
            _keyController.text.isEmpty || _valueController.text.isEmpty
                ? null
                : () => Navigator.of(
                  context,
                ).pop(MapEntry(_keyController.text, _valueController.text)),
        child: const Text('Add'),
      ),
    ],
  );
}
