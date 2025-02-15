import 'package:sointent/common_imports.dart';

/// {@template ui_intent_editor}
/// Center panel of the workbench that provides editing capabilities
/// for the currently selected intent.
/// {@endtemplate}
class UiIntentEditor extends HookWidget {
  /// {@macro ui_intent_editor}
  const UiIntentEditor({super.key});

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<SemanticIntentsResource>();
    final messages = context.watch<DialogMessagesResource>();

    return const Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Intent Editor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter intent YAML here...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
