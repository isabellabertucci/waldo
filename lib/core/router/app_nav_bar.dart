import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The floating pill navbar. Item order must match the router's branch order.
/// The selected tab's stitched pill stretches to the next tab picked.
class AppNavBar extends StatefulWidget {
  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  /// One per tab, so the pill can find where the selected tab is.
  final _tabKeys = List.generate(3, (_) => GlobalKey());

  void _select(int index) {
    if (index != widget.currentIndex) HapticFeedback.selectionClick();
    widget.onSelect(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.currentIndex;
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

    final bar = SafeArea(
      minimum: const EdgeInsets.fromLTRB(Spacing.sm, 0, Spacing.sm, Spacing.xs),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: DynamicTypeScaler.barMaxScale,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: colors.sheet,
                borderRadius: BorderRadius.circular(Rounded.pill),
                // An outline rather than a shadow, as everything that floats.
                border: Border.all(color: colors.line),
              ),
              // A tab bar to screen readers, as Flutter's NavigationBar is.
              child: Semantics(
                role: SemanticsRole.tabBar,
                explicitChildNodes: true,
                container: true,
                child: StretchPill(
                  selectedKey: _tabKeys[currentIndex],
                  color: colors.navActive,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(width: Spacing.xs / 2),
                        KeyedSubtree(
                          key: _tabKeys[i],
                          child: AppNavButton(
                            key: ValueKey('nav-$i'),
                            icon: items[i].icon,
                            selectedIcon: items[i].selectedIcon,
                            label: items[i].label,
                            selected: i == currentIndex,
                            tabIndex: i + 1,
                            tabCount: items.length,
                            onTap: () => _select(i),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // The page fades out under the bar, no higher than the bar itself, so
    // rows don't run into it. Behind it and not tappable: a touch beside the
    // pill still reaches the page.
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.sheet.withValues(alpha: 0), colors.sheet],
                  stops: const [0, 0.5],
                ),
              ),
            ),
          ),
        ),
        bar,
      ],
    );
  }
}

/// One navbar destination: the selected tab shows its label on the navbar's
/// pill, the others are icon-only circles.
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
          // The pill itself is the navbar's StretchPill, painted behind;
          // the label opens as it arrives and closes as it leaves.
          child: AnimatedPadding(
            duration: context.motion(Motion.pillStretch),
            curve: Motion.emphasizedCurve,
            padding: selected
                ? const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: ComponentSize.navSelectedPadding,
                  )
                : const EdgeInsets.all(Spacing.component),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    end: selected ? colors.onNavActive : colors.inkMuted,
                  ),
                  duration: context.motion(Motion.pillLabel),
                  builder: (context, color, _) => Icon(
                    selected ? selectedIcon : icon,
                    size: IconSize.lg,
                    color: color,
                  ),
                ),
                AnimatedSwitcher(
                  duration: context.motion(Motion.pillStretch),
                  switchInCurve: Motion.emphasizedCurve,
                  switchOutCurve: Motion.emphasizedCurve,
                  transitionBuilder: (child, animation) => SizeTransition(
                    axis: Axis.horizontal,
                    alignment: AlignmentDirectional.centerStart,
                    sizeFactor: animation,
                    // Only the width opens; the height stays the label's.
                    fixedCrossAxisSizeFactor: 1,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: selected
                      ? Row(
                          key: const ValueKey(true),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: Spacing.xs),
                            Text(
                              label,
                              style: context.bodyStrong.copyWith(
                                color: colors.onNavActive,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
