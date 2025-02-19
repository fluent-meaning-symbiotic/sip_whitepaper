import 'package:flutter/material.dart';

class CenterPanelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CenterPanelAppBar({
    required this.title,
    required this.isLeftPanelVisible,
    required this.isRightPanelVisible,
    required this.onShowLeftPanel,
    required this.onShowRightPanel,
    this.onSave,
    this.onUndo,
    this.onRedo,
    super.key,
  });

  final String title;
  final VoidCallback? onSave;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool isLeftPanelVisible;
  final bool isRightPanelVisible;
  final VoidCallback onShowLeftPanel;
  final VoidCallback onShowRightPanel;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(final BuildContext context) => AppBar(
    leading:
        !isLeftPanelVisible
            ? Hero(
              tag: 'left_panel_toggle',
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onShowLeftPanel,
                tooltip: 'Show intents panel',
                iconSize: 20,
              ),
            )
            : null,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: onSave,
        tooltip: 'Save changes',
        iconSize: 20,
      ),
      IconButton(
        icon: const Icon(Icons.undo),
        onPressed: onUndo,
        tooltip: 'Undo last change',
        iconSize: 20,
      ),
      IconButton(
        icon: const Icon(Icons.redo),
        onPressed: onRedo,
        tooltip: 'Redo last change',
        iconSize: 20,
      ),
      if (!isRightPanelVisible)
        Hero(
          tag: 'right_panel_toggle',
          child: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onShowRightPanel,
            tooltip: 'Show controls panel',
            iconSize: 20,
          ),
        ),
    ],
  );
}
