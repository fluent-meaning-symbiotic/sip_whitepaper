import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_intents_view/card_view/commands/move_intent_path.cmd.dart';
import 'package:sointent/ui_intents_view/card_view/path_editor_tool.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

class IntentPathChips extends StatefulWidget {
  const IntentPathChips({required this.intent, super.key});

  final SemanticIntentFile intent;

  @override
  State<IntentPathChips> createState() => _IntentPathChipsState();
}

class _IntentPathChipsState extends State<IntentPathChips> {
  final _newFolderController = TextEditingController();
  bool _isAddingFolder = false;

  @override
  void dispose() {
    _newFolderController.dispose();
    super.dispose();
  }

  void _handleChipTap(final int index, final List<String> segments) {
    // TODO: Implement path navigation
  }

  void _handleAddFolder() {
    setState(() => _isAddingFolder = true);
  }

  Future<void> _handleRemoveFolder() async {
    final projectPath = context.read<IntentsFolderResource>().value;
    final segments = widget.intent.getRelativePath(projectPath).split('/')
      ..removeWhere((final s) => s.isEmpty);

    if (segments.length <= 2) return; // Don't remove if only lib/ and filename

    try {
      final newPath = PathEditorTool.removeSegment(
        segments.join('/'),
        segments.length - 2, // Remove parent folder of the file
      );

      await MoveIntentPathCommand(
        intent: widget.intent,
        newPath: newPath,
      ).execute();
    } catch (e) {
      print('Path removal error: $e'); // For debugging
    }
  }

  Future<void> _handleNewFolderSubmit() async {
    if (_newFolderController.text.isEmpty) {
      setState(() => _isAddingFolder = false);
      return;
    }

    final segments = widget.intent.path.split('/')
      ..removeWhere((final s) => s.isEmpty);

    try {
      final newPath = PathEditorTool.addSegment(
        segments.join('/'),
        _newFolderController.text,
        segments.length - 1, // Insert before filename
      );

      await MoveIntentPathCommand(
        intent: widget.intent,
        newPath: newPath,
      ).execute();
    } catch (e) {
      print('Path add error: $e'); // For debugging
    }

    _newFolderController.clear();
    setState(() => _isAddingFolder = false);
  }

  List<String> _getPathSegments() {
    final projectPath = context.read<IntentsFolderResource>().value;
    final segments = widget.intent.getRelativePath(projectPath).split('/')
      ..removeWhere((final s) => s.isEmpty);

    // Ensure lib/ prefix is preserved
    if (segments.isEmpty || segments[0] != 'lib') {
      segments.insert(0, 'lib');
    }

    // Remove filename from segments
    if (segments.length > 1) {
      segments.removeLast();
    }

    return segments;
  }

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    final segments = _getPathSegments();

    return Row(
      children: [
        // Path chips
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    Text(
                      '/',
                      style: TextStyle(
                        color: theme.secondaryText.withOpacity(0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  _PathChip(label: segments[i]),
                ],
                if (_isAddingFolder) ...[
                  Text(
                    '/',
                    style: TextStyle(
                      color: theme.secondaryText.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Path manipulation buttons
        if (_isAddingFolder)
          SizedBox(
            width: 80,
            height: 20,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _newFolderController,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 4,
                      right: 24,
                      top: 2,
                      bottom: 2,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(
                        color: theme.primaryAccent.withOpacity(0.2),
                      ),
                    ),
                  ),
                  onSubmitted: (_) async {
                    await _handleNewFolderSubmit();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check, size: 12),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  color: theme.primaryAccent,
                  onPressed: () async {
                    await _handleNewFolderSubmit();
                  },
                ),
              ],
            ),
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.add, size: 12),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            color: theme.secondaryText.withOpacity(0.5),
            onPressed: _handleAddFolder,
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 12),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            color: theme.secondaryText.withOpacity(0.5),
            onPressed:
                segments.length > 1
                    ? () async {
                      await _handleRemoveFolder();
                    }
                    : null,
          ),
        ],
      ],
    );
  }
}

class _PathChip extends StatelessWidget {
  const _PathChip({required this.label, this.isHighlighted = false});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? theme.primaryAccent.withOpacity(0.1)
                : theme.baseBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.secondaryText,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
