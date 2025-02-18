import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';

/// A reusable dropdown field component with consistent styling
class DropdownField<T> extends StatelessWidget {
  /// Creates a new [DropdownField] instance
  const DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  /// The label text for the field
  final String label;

  /// The currently selected value
  final T value;

  /// The list of dropdown items
  final List<DropdownMenuItem<T>> items;

  /// Callback when the selection changes
  final ValueChanged<T?> onChanged;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Find the currently selected item to display its child
    final selectedItem = items.firstWhere(
      (final item) => item.value == value,
      orElse: () => items.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelStyle),
        const SizedBox(height: 8),
        Container(
          height: 36, // From design tokens
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // Light shadow (top-left)
              BoxShadow(
                color:
                    colorScheme.brightness == Brightness.light
                        ? const Color(0x1A6B63FF)
                        : const Color(0x0F7B63FF),
                blurRadius: 2,
                offset: const Offset(-0.5, -0.5),
              ),
              // Dark shadow (bottom-right)
              BoxShadow(
                color:
                    colorScheme.brightness == Brightness.light
                        ? const Color(0x33000000)
                        : const Color(0x4D000000),
                blurRadius: 2,
                offset: const Offset(0.5, 0.5),
              ),
            ],
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: PopupMenuButton<T>(
            initialValue: value,
            onSelected: onChanged,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
            ),
            color: colorScheme.surface,
            elevation: 8,
            itemBuilder:
                (final context) =>
                    items.map((final item) {
                      final isSelected = item.value == value;
                      return PopupMenuItem<T>(
                        value: item.value,
                        child: Row(
                          children: [
                            Expanded(
                              child: DefaultTextStyle(
                                style: context.bodyStyle.copyWith(
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                ),
                                child: item.child,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: context.bodyStyle,
                      child: selectedItem.child,
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
