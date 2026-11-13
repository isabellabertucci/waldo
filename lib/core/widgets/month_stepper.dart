import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// "‹ November ›": one month of [months], a step back or forward at a time.
/// The way forward is in ink, so it's the one that stands out once you've
/// gone back; either end is dimmed.
class MonthStepper extends StatelessWidget {
  const MonthStepper({
    super.key,
    required this.months,
    required this.month,
    required this.onChanged,
  });

  /// Oldest first.
  final List<DateTime> months;
  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final index = months.indexWhere(
      (m) => m.year == month.year && m.month == month.month,
    );
    final last = months.isEmpty ? null : months.last;
    // The year too once it isn't the latest month's.
    final label = last != null && month.year == last.year
        ? DateFormat.MMMM(locale).format(month)
        : DateFormat.yMMMM(locale).format(month);
    final canGoBack = index > 0;
    final canGoForward = index >= 0 && index < months.length - 1;

    Widget arrow({
      required IconData icon,
      required String tooltip,
      required bool enabled,
      required VoidCallback onPressed,
      bool ink = false,
    }) {
      final button = CircleIconButton(
        flat: true,
        tint: ink ? colors.ink : colors.card,
        tooltip: tooltip,
        onPressed: enabled ? onPressed : () {},
        child: Icon(
          icon,
          size: IconSize.lg,
          color: ink ? colors.onInk : colors.ink,
        ),
      );
      if (enabled) return button;
      // Dimmed at either end of the range, and out of the tab order.
      return ExcludeSemantics(
        child: IgnorePointer(
          child: Opacity(opacity: Alpha.line, child: button),
        ),
      );
    }

    return Row(
      children: [
        arrow(
          icon: AppIcons.back,
          tooltip: l10n.previousMonth,
          enabled: canGoBack,
          onPressed: () => onChanged(months[index - 1]),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.titleCard,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        arrow(
          icon: AppIcons.chevronRight,
          tooltip: l10n.nextMonth,
          enabled: canGoForward,
          ink: canGoForward,
          onPressed: () => onChanged(months[index + 1]),
        ),
      ],
    );
  }
}
