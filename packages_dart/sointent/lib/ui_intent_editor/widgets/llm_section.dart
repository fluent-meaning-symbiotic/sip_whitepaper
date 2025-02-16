import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intent_editor/controllers/structured_intent_controller.dart';
import 'package:sointent/ui_intent_editor/widgets/map_editor_dialog.dart';
import 'package:sointent/ui_intent_editor/widgets/map_view.dart';

/// Section for editing LLM prompts and scratchpad
class LlmSection extends StatefulWidget {
  /// Creates a new instance of [LlmSection]
  const LlmSection({required this.controller, super.key});

  /// The controller managing the intent data
  final StructuredIntentController controller;

  @override
  State<LlmSection> createState() => _LlmSectionState();
}

class _LlmSectionState extends State<LlmSection> {
  late final TextEditingController _scratchpadController;

  @override
  void initState() {
    super.initState();
    _scratchpadController = TextEditingController(
      text: widget.controller.data.scratchpadTodo,
    );
  }

  @override
  void dispose() {
    _scratchpadController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(final LlmSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _scratchpadController.text = widget.controller.data.scratchpadTodo;
    }
  }

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'LLM Prompts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await showDialog<MapEntry<String, dynamic>>(
                    context: context,
                    builder:
                        (final context) =>
                            const MapEditorDialog(title: 'Add LLM Prompt'),
                  );

                  if (result != null) {
                    widget.controller.updateLlmPrompts({
                      result.key: result.value,
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          MapView(
            items: widget.controller.data.llmPrompts,
            onRemove: (final key) {
              final newPrompts = Map<String, dynamic>.from(
                widget.controller.data.llmPrompts,
              )..remove(key);
              widget.controller.updateLlmPrompts(newPrompts);
            },
          ),
          const Divider(height: 32),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Scratchpad/Todo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          TextField(
            maxLines: null,
            controller: _scratchpadController,
            onChanged: widget.controller.updateScratchpadTodo,
            decoration: const InputDecoration(
              hintText: 'Enter notes, todos, or reminders here...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  );
}
