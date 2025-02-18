import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/atoms/atoms.dart';

/// {@template ui_intent_controls}
/// Right panel of the workbench that displays controls and actions
/// for the currently selected intent.
/// {@endtemplate}
class UiIntentControls extends HookWidget {
  /// {@macro ui_intent_controls}
  const UiIntentControls({super.key});

  @override
  Widget build(final BuildContext context) {
    final intents = context.watch<IntentsResource>();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Intent Controls', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            NeumorphicButton(
              label: 'Create Intent',
              onPressed: () {
                // TODO: Implement create intent
              },
              icon: Icons.add,
            ),
            const SizedBox(height: 8),
            NeumorphicButton(
              label: 'Save Intent',
              onPressed: () {
                // TODO: Implement save intent
              },
              icon: Icons.save,
            ),
            const SizedBox(height: 8),
            NeumorphicButton(
              label: 'Delete Intent',
              onPressed: () {
                // TODO: Implement delete intent
              },
              icon: Icons.delete,
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
