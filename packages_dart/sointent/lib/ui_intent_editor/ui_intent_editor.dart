import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/data_resources.dart';

/// {@template intent_editor_screen}
/// Screen for editing a semantic intent.
/// {@endtemplate}
class IntentEditorScreen extends HookWidget {
  /// {@macro intent_editor_screen}
  const IntentEditorScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<SemanticIntentsResource>();
    final messages = context.watch<DialogMessagesResource>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intent Editor'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: context.pop),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Intent Editor Coming Soon',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
