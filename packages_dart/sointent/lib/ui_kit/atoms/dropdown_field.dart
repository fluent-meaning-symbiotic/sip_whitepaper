import 'package:flutter/material.dart';
import 'package:sointent/ui_kit/atoms/text_styles.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

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
    final neumorphicTheme = AppTheme.of(context);

    // Find the currently selected item to display its child
    final selectedItem = items.firstWhere(
      (final item) => item.value == value,
      orElse: () => items.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelStyle),
        const SizedBox(height: tokens.Spacing.micro * 2),
        SizedBox(
          height: tokens.ComponentSize.inputHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: neumorphicTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(
                tokens.ComponentSize.buttonRadius,
              ),
              boxShadow: [
                // Light shadow (top-left)
                BoxShadow(
                  color: neumorphicTheme.lightShadow,
                  blurRadius: tokens.Elevation.defaultDesktop,
                  offset: const Offset(-0.5, -0.5),
                ),
                // Dark shadow (bottom-right)
                BoxShadow(
                  color: neumorphicTheme.darkShadow,
                  blurRadius: tokens.Elevation.defaultDesktop,
                  offset: const Offset(0.5, 0.5),
                ),
              ],
              border: Border.all(
                color: neumorphicTheme.primaryText.withOpacity(
                  tokens.EnhancementTokens.borderLuminosityDiff,
                ),
              ),
            ),
            child: PopupMenuButton<T>(
              initialValue: value,
              onSelected: onChanged,
              position: PopupMenuPosition.under,
              offset: const Offset(0, tokens.Spacing.micro),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  tokens.ComponentSize.buttonRadius,
                ),
                side: BorderSide(
                  color: neumorphicTheme.primaryText.withOpacity(
                    tokens.EnhancementTokens.borderLuminosityDiff,
                  ),
                ),
              ),
              color: neumorphicTheme.surfaceBackground,
              elevation: tokens.Elevation.floatingDark,
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
                                            ? neumorphicTheme.primaryAccent
                                            : neumorphicTheme.primaryText,
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
                                  size: tokens.ComponentSize.actionIconSize,
                                  color: neumorphicTheme.primaryAccent,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: tokens.Spacing.horizontalElement,
                  vertical: tokens.Spacing.verticalElement / 1.5,
                ),
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
                      size: tokens.ComponentSize.navIconSize,
                      color: neumorphicTheme.primaryText.withOpacity(
                        tokens.StateModifiers.disabledOpacity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
