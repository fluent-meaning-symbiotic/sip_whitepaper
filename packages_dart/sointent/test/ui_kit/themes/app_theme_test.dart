import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';
import 'package:sointent/ui_kit/tokens/design_tokens.dart' as tokens;

void main() {
  group('AppTheme Golden Tests', () {
    unawaited(
      goldenTest(
        'Light theme color relationships',
        fileName: 'light_theme_colors',
        builder:
            () => GoldenTestGroup(
              children: [
                GoldenTestScenario(
                  name: 'Color Palette',
                  child: ColorPaletteWidget(
                    theme: AppTheme.lightTheme,
                    neumorphicTheme:
                        AppTheme.lightTheme.extension<NeumorphicTheme>()!,
                  ),
                ),
              ],
            ),
      ),
    );

    unawaited(
      goldenTest(
        'Dark theme color relationships',
        fileName: 'dark_theme_colors',
        builder:
            () => GoldenTestGroup(
              children: [
                GoldenTestScenario(
                  name: 'Color Palette',
                  child: ColorPaletteWidget(
                    theme: AppTheme.darkTheme,
                    neumorphicTheme:
                        AppTheme.darkTheme.extension<NeumorphicTheme>()!,
                  ),
                ),
              ],
            ),
      ),
    );

    unawaited(
      goldenTest(
        'Typography scale',
        fileName: 'typography_scale',
        builder:
            () => GoldenTestGroup(
              children: [
                GoldenTestScenario(
                  name: 'Typography Scale',
                  child: const TypographyScaleWidget(),
                ),
              ],
            ),
      ),
    );
  });
}

/// Widget to display color palette for golden tests
class ColorPaletteWidget extends StatelessWidget {
  const ColorPaletteWidget({
    required this.theme,
    required this.neumorphicTheme,
    super.key,
  });

  final ThemeData theme;
  final NeumorphicTheme neumorphicTheme;

  @override
  Widget build(final BuildContext context) => Container(
    padding: tokens.Spacing.sectionPadding,
    color: neumorphicTheme.baseBackground,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorRow('Base Background', neumorphicTheme.baseBackground),
        _buildColorRow('Surface Background', neumorphicTheme.surfaceBackground),
        _buildColorRow('Primary Accent', neumorphicTheme.primaryAccent),
        _buildColorRow('Secondary Accent', neumorphicTheme.secondaryAccent),
        _buildColorRow('Primary Text', neumorphicTheme.primaryText),
        _buildColorRow('Secondary Text', neumorphicTheme.secondaryText),
        _buildColorRow('Light Shadow', neumorphicTheme.lightShadow),
        _buildColorRow('Dark Shadow', neumorphicTheme.darkShadow),
      ],
    ),
  );

  Widget _buildColorRow(final String label, final Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: tokens.Typography.primary.copyWith(
                color: neumorphicTheme.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
              style: tokens.Typography.code.copyWith(
                color: neumorphicTheme.secondaryText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Widget to display typography scale for golden tests
class TypographyScaleWidget extends StatelessWidget {
  const TypographyScaleWidget({super.key});

  @override
  Widget build(final BuildContext context) => Container(
    padding: tokens.Spacing.sectionPadding,
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary Text Style', style: tokens.Typography.primary),
        const SizedBox(height: 16),
        Text('Primary Dark Text Style', style: tokens.Typography.primaryDark),
        const SizedBox(height: 16),
        Text('Secondary Text Style', style: tokens.Typography.secondary),
        const SizedBox(height: 16),
        Text('Header Text Style', style: tokens.Typography.header),
        const SizedBox(height: 16),
        Text('Code Text Style', style: tokens.Typography.code),
      ],
    ),
  );
}
