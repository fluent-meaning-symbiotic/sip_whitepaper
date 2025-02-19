import 'package:flutter/material.dart';

class LeftPanelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LeftPanelAppBar({
    required this.isVisible,
    required this.onToggleVisibility,
    super.key,
  });

  final bool isVisible;
  final VoidCallback onToggleVisibility;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(final BuildContext context) => AppBar(
    title: const Text(
      'Intents',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(isVisible ? Icons.chevron_left : Icons.chevron_right),
        onPressed: onToggleVisibility,
        tooltip: isVisible ? 'Hide intents panel' : 'Show intents panel',
      ),
    ],
  );
}
