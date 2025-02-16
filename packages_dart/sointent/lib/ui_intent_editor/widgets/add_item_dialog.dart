import 'package:sointent/common_imports.dart';

/// Dialog for adding new items with AI suggestions
class AddItemDialog extends StatefulWidget {
  /// Creates a new instance of [AddItemDialog]
  const AddItemDialog({
    required this.title,
    required this.suggestions,
    super.key,
  });

  /// The title of the dialog
  final String title;

  /// The list of AI-powered suggestions
  final List<String> suggestions;

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _controller = TextEditingController();
  String? _selectedSuggestion;

  @override
  void dispose() {
    _controller.dispose();
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
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'New Item',
            border: OutlineInputBorder(),
          ),
          onChanged: (final value) {
            setState(() {
              _selectedSuggestion = null;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Suggestions:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              widget.suggestions.map((final suggestion) {
                final isSelected = suggestion == _selectedSuggestion;
                return FilterChip(
                  label: Text(suggestion),
                  selected: isSelected,
                  onSelected: (final selected) {
                    setState(() {
                      if (selected) {
                        _selectedSuggestion = suggestion;
                        _controller.text = suggestion;
                      } else {
                        _selectedSuggestion = null;
                      }
                    });
                  },
                );
              }).toList(),
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
            _controller.text.isEmpty
                ? null
                : () => Navigator.of(context).pop(_controller.text),
        child: const Text('Add'),
      ),
    ],
  );
}
