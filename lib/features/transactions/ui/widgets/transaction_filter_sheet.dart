import 'package:flutter/material.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/month_selector.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import '../../models/transaction_filter.dart';
import '../../transactions_x.dart';

/// Bottom sheet to filter a wallet's transactions by month and type.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    required this.initial,
    required this.locale,
    required this.now,
    required this.countForFilter,
  });

  final TransactionFilter initial;
  final String locale;
  final DateTime now;
  final int Function(TransactionFilter filter) countForFilter;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionFilter _filter;
  late final List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _filter = widget.initial;
    final now = widget.now;
    _months = selectorMonths(now);
  }

  void _reset() {
    final now = widget.now;
    setState(
      () => _filter = TransactionFilter(month: DateTime(now.year, now.month)),
    );
  }

  void _selectType(TransactionType? type) {
    setState(() => _filter = _filter.copyWith(type: type));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final count = widget.countForFilter(_filter);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Rounded.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetGrabber(),
            const SizedBox(height: Spacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  Heading(
                    child: Text(
                      l10n.filterTitle,
                      style: context.headlineLgExtraBold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onSurfaceVariant,
                    ),
                    child: Text(l10n.filterReset),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Heading(
                  child: Text(
                    l10n.filterSectionType.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Container(
                // The top and bottom margin is inside each segment's touch.
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: Alpha.faint),
                  borderRadius: BorderRadius.circular(Rounded.pill),
                ),
                // Segmented controls stop growing where bars do, as on iOS.
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: DynamicTypeScaler.barMaxScale,
                  child: Row(
                    children: [
                      _TypeSegment(
                        label: l10n.filterTypeAll,
                        selected: _filter.type == null,
                        onTap: () => _selectType(null),
                      ),
                      _TypeSegment(
                        label: TransactionType.income.label(l10n),
                        selected: _filter.type == TransactionType.income,
                        onTap: () => _selectType(TransactionType.income),
                      ),
                      _TypeSegment(
                        label: TransactionType.expense.label(l10n),
                        selected: _filter.type == TransactionType.expense,
                        onTap: () => _selectType(TransactionType.expense),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Heading(
                  child: Text(
                    l10n.filterSectionMonth.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            MonthSelector(
              months: _months,
              selectedMonth: _filter.month,
              currentMonth: DateTime(widget.now.year, widget.now.month),
              locale: widget.locale,
              onSelect: (month) =>
                  setState(() => _filter = _filter.copyWith(month: month)),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  label: l10n.filterShowTransactions(count),
                  onPressed: () => Navigator.of(context).pop(_filter),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: Semantics(
        // One choice of three, like Flutter's SegmentedButton.
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: GestureDetector(
          // Taps on the track's margin count too: a 48px-tall touch.
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
            child: Material(
              color: selected ? colors.surface : colors.transparent,
              borderRadius: BorderRadius.circular(Rounded.pill),
              elevation: selected ? 1 : 0,
              shadowColor: Elevation.highShadowColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(Rounded.pill),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Spacing.component,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style:
                        (selected ? context.bodySmBold : context.bodySmStrong)
                            .copyWith(
                              color: selected
                                  ? colors.onSurface
                                  : colors.onSurfaceVariant,
                            ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
