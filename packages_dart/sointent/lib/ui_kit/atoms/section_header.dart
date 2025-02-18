import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';

/// A reusable section header component with consistent styling
class SectionHeader extends StatelessWidget {
  /// Creates a new [SectionHeader] instance
  const SectionHeader({required this.title, this.action, super.key});

  /// The title of the section
  final String title;

  /// Optional action widget (usually an IconButton)
  final Widget? action;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: context.sectionTitleStyle)),
      if (action != null) action!,
    ],
  );
}
