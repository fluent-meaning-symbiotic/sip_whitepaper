import 'package:sointent/common_imports.dart';

/// {@template ui_intents_view}
/// A widget that displays a hierarchical view of semantic intents using horizontal panels.
/// Each panel represents one level of the path hierarchy.
/// {@endtemplate}
class UiIntentsView extends StatefulWidget {
  /// {@macro ui_intents_view}
  const UiIntentsView({super.key});

  @override
  State<UiIntentsView> createState() => _UiIntentsViewState();
}

class _UiIntentsViewState extends State<UiIntentsView> {
  late final List<String> _selectedPaths;
  late final Map<int, Map<String, List<SemanticIntentFile>>> _levels;
  late final Map<String, List<String>> _subpaths;

  @override
  void initState() {
    super.initState();
    _selectedPaths = [];
    _levels = {};
    _subpaths = {};
    _initializeData();
  }

  void _initializeData() {
    final intentsResource = context.read<IntentsResource>();

    // First pass: collect all paths and their subpaths
    for (final intent in intentsResource.orderedValues) {
      final segments = intent.path.split('/');
      final parentPath = segments.take(segments.length - 1).join('/');
      final level = parentPath.isEmpty ? 0 : parentPath.split('/').length;

      // Initialize level if needed
      _levels.putIfAbsent(level, () => {});

      // Add intent to its parent path
      _levels[level]!.update(
        parentPath,
        (final files) => files..add(intent),
        ifAbsent: () => [intent],
      );

      // Build subpath relationships
      var currentPath = '';
      for (var i = 0; i < segments.length - 1; i++) {
        final segment = segments[i];
        final nextPath =
            currentPath.isEmpty ? segment : '$currentPath/$segment';

        _subpaths.update(
          currentPath,
          (final paths) => paths..add(segment),
          ifAbsent: () => [segment],
        );

        currentPath = nextPath;
      }
    }
  }

  List<String> _getPathsForLevel(final int level) {
    if (level == 0) {
      return _subpaths[''] ?? const <String>[];
    }

    if (level >= _selectedPaths.length) {
      return const <String>[];
    }

    final parentPath = _selectedPaths[level - 1];
    return _subpaths[parentPath] ?? const <String>[];
  }

  void _handlePathSelected(final int level, final String path) {
    final parentPath = level == 0 ? '' : _selectedPaths[level - 1];
    final fullPath = parentPath.isEmpty ? path : '$parentPath/$path';

    setState(() {
      _selectedPaths
        ..length = level
        ..add(fullPath);
    });
  }

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Create a panel for each selected level
        for (var level = 0; level <= _selectedPaths.length; level++)
          LevelPanel(
            level: level,
            selectedPath:
                level < _selectedPaths.length ? _selectedPaths[level] : null,
            paths: _getPathsForLevel(level),
            intents:
                (level < _selectedPaths.length
                    ? (_levels[level]?[_selectedPaths[level]])
                    : null) ??
                const <SemanticIntentFile>[],
            onPathSelected: (final path) => _handlePathSelected(level, path),
          ),
      ],
    ),
  );
}

/// {@template level_panel}
/// A panel that displays the contents of a specific path level.
/// {@endtemplate}
class LevelPanel extends StatelessWidget {
  /// {@macro level_panel}
  const LevelPanel({
    required this.level,
    required this.selectedPath,
    required this.paths,
    required this.intents,
    required this.onPathSelected,
    super.key,
  });

  /// The level in the hierarchy (0-based)
  final int level;

  /// The currently selected path at this level
  final String? selectedPath;

  /// Available paths at this level
  final List<String> paths;

  /// Intents at the selected path
  final List<SemanticIntentFile> intents;

  /// Callback when a path is selected
  final void Function(String path) onPathSelected;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250, // Fixed width for each panel
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Panel header
            Container(
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.primaryContainer,
              child: Text(
                'Level ${level + 1}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            // Path/Intent list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: paths.length + intents.length,
                itemBuilder: (final context, final index) {
                  if (index < paths.length) {
                    // Show path item
                    final path = paths[index];
                    final isSelected = path == selectedPath;
                    final name = path.split('/').last;

                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.folder,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(name, style: theme.textTheme.bodyMedium),
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primaryContainer
                          .withOpacity(0.3),
                      onTap: () => onPathSelected(path),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                    );
                  } else {
                    // Show intent item
                    final intent = intents[index - paths.length];

                    return IntentListItem(
                      intent: intent,
                      isSelected: false, // No selection for intents yet
                      onTap: () {}, // No action for intents yet
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template intent_list_item}
/// A list item that displays information about a semantic intent.
/// {@endtemplate}
class IntentListItem extends StatelessWidget {
  /// {@macro intent_list_item}
  const IntentListItem({
    required this.intent,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// The intent to display
  final SemanticIntentFile intent;

  /// Whether this intent is currently selected
  final bool isSelected;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.description,
        size: 20,
        color: theme.colorScheme.primary.withOpacity(0.7),
      ),
      title: Text(intent.name.value, style: theme.textTheme.bodyMedium),
      subtitle: Text(intent.type.name, style: theme.textTheme.bodySmall),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      onTap: onTap,
    );
  }
}
