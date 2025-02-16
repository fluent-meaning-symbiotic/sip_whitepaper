import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';

/// Section for editing basic intent properties
class BasicPropertiesSection extends StatefulWidget {
  /// Creates a new instance of [BasicPropertiesSection]
  const BasicPropertiesSection({required this.controller, super.key});

  /// The controller managing the intent data
  final StructuredIntentController controller;

  @override
  State<BasicPropertiesSection> createState() => _BasicPropertiesSectionState();
}

class _BasicPropertiesSectionState extends State<BasicPropertiesSection> {
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
  void didUpdateWidget(final BasicPropertiesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _nameController.text = widget.controller.data.name;
      _meaningController.text = widget.controller.data.meaning;
      _descriptionController.text = widget.controller.data.description;
    }
  }

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Properties',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            controller: _nameController,
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(name: value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SemanticIntentType>(
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            value: SemanticIntentType.values.firstWhere(
              (final t) => t.json == widget.controller.data.type,
              orElse: () => SemanticIntentType.type,
            ),
            items:
                SemanticIntentType.values
                    .map(
                      (final type) =>
                          DropdownMenuItem(value: type, child: Text(type.json)),
                    )
                    .toList(),
            onChanged: (final value) {
              if (value != null) {
                widget.controller.updateBasicProperties(type: value.json);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Meaning',
              border: OutlineInputBorder(),
              helperText: "Core meaning of the intent's purpose",
            ),
            scrollPhysics: const NeverScrollableScrollPhysics(),
            controller: _meaningController,
            maxLines: null,
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(meaning: value),
          ),
          const SizedBox(height: 16),
          TextField(
            scrollPhysics: const NeverScrollableScrollPhysics(),
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              helperText: 'Detailed description of the intent',
            ),
            controller: _descriptionController,
            onChanged:
                (final value) =>
                    widget.controller.updateBasicProperties(description: value),
          ),
        ],
      ),
    ),
  );
}
