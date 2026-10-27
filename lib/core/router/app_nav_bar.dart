import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/dash_path.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The selected pill's label is shorter than the icon-only buttons are tall,
/// so it takes one more pixel each side to keep every button the same height.
const _selectedVerticalPadding = 13.0; // one-off

/// The floating pill navbar. Item order must match the router's branch order.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    final items = [
      (
        icon: AppIcons.dashboard,
        selectedIcon: AppIcons.dashboardSelected,
        label: l10n.dashboard,
      ),
      (
        icon: AppIcons.wallets,
        selectedIcon: AppIcons.walletsSelected,
        label: l10n.wallets,
      ),
      (
        icon: AppIcons.settings,
        selectedIcon: AppIcons.settingsSelected,
        label: l10n.settings,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(Spacing.sm, 0, Spacing.sm, Spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(Rounded.pill),
              boxShadow: Elevation.low,
            ),
            // A tab bar to screen readers, as Flutter's NavigationBar is.
            child: Semantics(
              role: SemanticsRole.tabBar,
              explicitChildNodes: true,
              container: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: Spacing.xs / 2),
                    AppNavButton(
                      key: ValueKey('nav-$i'),
                      icon: items[i].icon,
                      selectedIcon: items[i].selectedIcon,
                      label: items[i].label,
                      selected: i == currentIndex,
                      tabIndex: i + 1,
                      tabCount: items.length,
                      onTap: () => onSelect(i),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One navbar destination: the selected tab is a filled pill with its label,
/// the others are icon-only circles.
class AppNavButton extends StatelessWidget {
  const AppNavButton({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.tabIndex,
    required this.tabCount,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;

  /// Its place in the bar, from 1, read as "Tab 2 of 3".
  final int tabIndex;
  final int tabCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.transparent,
      borderRadius: BorderRadius.circular(Rounded.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rounded.pill),
        onTap: onTap,
        // One node, as a NavigationBar destination: a selectable tab named
        // once (the visible label is excluded) with its place in the bar.
        child: Semantics(
          role: SemanticsRole.tab,
          button: true,
          selected: selected,
          label:
              '$label\n${MaterialLocalizations.of(context).tabLabel(tabIndex: tabIndex, tabCount: tabCount)}',
          excludeSemantics: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.transparent,
              borderRadius: BorderRadius.circular(Rounded.pill),
            ),
            // The stitch is painted over the whole pill, not inside its padding.
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DashedPillPainter(color: colors.onPrimary),
                    ),
                  ),
                Padding(
                  padding: selected
                      ? const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: _selectedVerticalPadding,
                        )
                      : const EdgeInsets.all(Spacing.component),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        size: IconSize.lg,
                        color: selected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                      if (selected) ...[
                        const SizedBox(width: Spacing.xs),
                        Text(
                          label,
                          style: context.labelLgBold.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed stitch just inside a pill's rounded edge.
class _DashedPillPainter extends CustomPainter {
  const _DashedPillPainter({required this.color});

  final Color color;

  // Denser and fainter than [PouchBorder]'s stitch, to suit the smaller pill.
  static const _inset = 5.0;
  static const _dashLength = 3.0;
  static const _gapLength = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(_inset),
          Radius.circular(rect.deflate(_inset).shortestSide / 2),
        ),
      );
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(
      dashPath(path, dashLength: _dashLength, gapLength: _gapLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedPillPainter oldDelegate) =>
      color != oldDelegate.color;
}
