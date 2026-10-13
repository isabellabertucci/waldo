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
          Row(
            children: [
              Expanded(
                child: Text(l10n.cashFlow, style: context.headlineMdStrong),
              ),
              _SeriesToggle(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
            ],
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
          _SeriesToggleSegment(
            label: l10n.transactionTypeExpense,
            selected: selected == TransactionType.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
          _SeriesToggleSegment(
            label: l10n.transactionTypeIncome,
            selected: selected == TransactionType.income,
            onTap: () => onChanged(TransactionType.income),
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
          child: Text(
            label,
            style: context.bodySmBold.copyWith(
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final lastIndex = monthlyCashFlow.length - 1;
                if (index < 0 || index > lastIndex) {
                  return const SizedBox.shrink();
                }
                // Every other month, to avoid overlap - but always the last one.
                if (index.isOdd && index != lastIndex) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Text(
                    monthFormat.format(monthlyCashFlow[index].month),
                    // Chart axis label - fl_chart's own small-print scale,
                    // not the app's type system.
                    style: TextStyle(
                      fontSize: 11,
                      color: labelColor,
                    ), // one-off
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
  }
}
