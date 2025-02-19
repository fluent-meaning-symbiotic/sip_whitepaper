import 'package:flutter/material.dart';

class RightPanelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RightPanelAppBar({
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
    leading: IconButton(
      icon: Icon(isVisible ? Icons.chevron_right : Icons.chevron_left),
      onPressed: onToggleVisibility,
      tooltip: isVisible ? 'Hide controls panel' : 'Show controls panel',
    ),
    title: const Text(
      'Controls',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),
  );
}
