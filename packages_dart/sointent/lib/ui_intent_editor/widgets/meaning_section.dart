import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

/// Section for editing basic intent properties
class MeaningSection extends StatefulWidget {
  /// Creates a new instance of [MeaningSection]
  const MeaningSection({required this.controller, super.key});

  /// The controller managing the intent data
  final StructuredIntentController controller;

  @override
  State<MeaningSection> createState() => _MeaningSectionState();
}

class _MeaningSectionState extends State<MeaningSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _meaningController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.data.name);
    _meaningController = TextEditingController(
      text: widget.controller.data.meaning,
    );
    _descriptionController = TextEditingController(
      text: widget.controller.data.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _meaningController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(final MeaningSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _nameController.text = widget.controller.data.name;
      _meaningController.text = widget.controller.data.meaning;
      _descriptionController.text = widget.controller.data.description;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColumnInputField(
            label: 'Name',
            controller: _nameController,
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(name: value),
          ),
          const SizedBox(height: 16),
          DropdownField<SemanticIntentType>(
            label: 'Type',
            value: SemanticIntentType.values.firstWhere(
              (final t) => t.json == widget.controller.data.type,
              orElse: () => SemanticIntentType.type,
            ),
            items:
                SemanticIntentType.values
                    .map(
                      (final type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.json, style: context.bodyStyle),
                      ),
                    )
                    .toList(),
            onChanged: (final value) {
              if (value != null) {
                widget.controller.updateBasicProperties(type: value.json);
              }
            },
          ),
          const SizedBox(height: 16),
          ColumnInputField(
            label: 'Meaning',
            controller: _meaningController,
            helperText: "Core meaning of the intent's purpose",
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(meaning: value),
          ),
          const SizedBox(height: 16),
          ColumnInputField(
            label: 'Description',
            controller: _descriptionController,
            helperText: 'Detailed description of the intent',
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(description: value),
          ),
        ],
      ),
    );
  }
}
