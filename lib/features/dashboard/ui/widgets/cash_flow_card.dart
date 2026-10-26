import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/dashboard_data.dart';
import 'package:waldo/features/transactions/transactions_x.dart';
import 'package:waldo/core/widgets/heading.dart';

/// One series (income or expense) at a time; exact values are in the tooltip.
class CashFlowCard extends StatefulWidget {
  const CashFlowCard({
    super.key,
    required this.monthlyCashFlow,
    required this.currency,
    required this.isBalanceHidden,
  });

  final List<MonthlyCashFlow> monthlyCashFlow;
  final Currency currency;

  /// Turns off the tap-to-see-amount tooltip; the line itself stays.
  final bool isBalanceHidden;

  @override
  State<CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<CashFlowCard> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = widget.currency.code;
    final locale = Localizations.localeOf(context).toString();
    final monthFormat = DateFormat.MMM(locale);
    final seriesColor = _selectedType == TransactionType.income
        ? colors.primaryStrong
        : colors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side by side when they fit; with large text the toggle wraps
          // under the title instead of squeezing it to a letter a line.
          // Full width, so spaceBetween has room to push the toggle right.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: Spacing.sm,
              children: [
                Heading(
                  child: Text(l10n.cashFlow, style: context.headlineMdStrong),
                ),
                _SeriesToggle(
                  selected: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            height: 160,
            child: _CashFlowChart(
              monthlyCashFlow: widget.monthlyCashFlow,
              currencyCode: currencyCode,
              locale: locale,
              monthFormat: monthFormat,
              selectedType: _selectedType,
              seriesColor: seriesColor,
              labelColor: colors.onSurfaceVariant,
              isBalanceHidden: widget.isBalanceHidden,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesToggle extends StatelessWidget {
  const _SeriesToggle({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _SeriesToggleSegment(
              label: TransactionType.expense.label(l10n),
              selected: selected == TransactionType.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Flexible(
            child: _SeriesToggleSegment(
              label: TransactionType.income.label(l10n),
              selected: selected == TransactionType.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesToggleSegment extends StatelessWidget {
  const _SeriesToggleSegment({
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

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.transparent,
            borderRadius: BorderRadius.circular(Rounded.pill),
          ),
          // Shrinks only when even a line of its own is too narrow (large
          // text on a small phone), so the word stays whole.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: context.bodySmBold.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({
    required this.monthlyCashFlow,
    required this.currencyCode,
    required this.locale,
    required this.monthFormat,
    required this.selectedType,
    required this.seriesColor,
    required this.labelColor,
    required this.isBalanceHidden,
  });

  final List<MonthlyCashFlow> monthlyCashFlow;
  final String currencyCode;
  final String locale;
  final DateFormat monthFormat;
  final TransactionType selectedType;
  final Color seriesColor;
  final Color labelColor;
  final bool isBalanceHidden;

  int _valueFor(MonthlyCashFlow month) =>
      selectedType == TransactionType.income ? month.income : month.expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spots = [
      for (var i = 0; i < monthlyCashFlow.length; i++)
        FlSpot(i.toDouble(), _valueFor(monthlyCashFlow[i]) / 100),
    ];

    // Chart axis label - fl_chart's own small-print scale, not the app's
    // type system.
    final labelStyle = TextStyle(fontSize: 11, color: labelColor); // one-off
    final labels = [
      for (final month in monthlyCashFlow) monthFormat.format(month.month),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Measured, so labels never overlap or get cut at any text size.
        final textScaler = MediaQuery.textScalerOf(context);
        var widest = 0.0;
        var tallest = 0.0;
        for (final label in labels) {
          final painter = TextPainter(
            // The theme's font too, as the Text below gets it.
            text: TextSpan(
              text: label,
              style: DefaultTextStyle.of(context).style.merge(labelStyle),
            ),
            textScaler: textScaler,
            textDirection: Directionality.of(context),
            maxLines: 1,
          )..layout();
          widest = max(widest, painter.width);
          tallest = max(tallest, painter.height);
          painter.dispose();
        }
        final lastIndex = labels.length - 1;
        final monthGap = lastIndex > 0
            ? constraints.maxWidth / lastIndex
            : constraints.maxWidth;
        // Every [step]th month, counted back from the last so it always shows.
        final step = max(1, ((widest + Spacing.xs) / monthGap).ceil());

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  // Asks for every month; [step] picks which get a label.
                  interval: 1,
                  reservedSize: tallest + Spacing.xs,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index > lastIndex) {
                      return const SizedBox.shrink();
                    }
                    if ((lastIndex - index) % step != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: Spacing.xs),
                      child: Text(
                        labels[index],
                        maxLines: 1,
                        style: labelStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: !isBalanceHidden,
              getTouchedSpotIndicator: (barData, indicators) =>
                  indicators.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: seriesColor.withValues(alpha: 0.4),
                        strokeWidth: 1.5,
                        dashArray: const [4, 4],
                      ),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: seriesColor,
                              strokeWidth: 2,
                              strokeColor: colors.surface,
                            ),
                      ),
                    );
                  }).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => colors.primaryStrong,
                tooltipBorderRadius: BorderRadius.circular(Rounded.pill),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                  final month = monthlyCashFlow[spot.spotIndex].month;
                  final amountCents = (spot.y * 100).round();
                  return LineTooltipItem(
                    '${monthFormat.format(month)} · '
                    '${formatCents(amountCents, locale: moneyLocale(context), currencyCode: currencyCode)}',
                    // Tooltip text drawn by fl_chart on the canvas, not a UI text style.
                    TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // one-off
                    ),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: seriesColor,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      seriesColor.withValues(alpha: 0.28),
                      seriesColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
