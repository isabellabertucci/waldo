import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/l10n/app_localizations.dart';

class CashFlowCard extends StatelessWidget {
  const CashFlowCard({
    super.key,
    required this.monthlyCashFlow,
    required this.currency,
  });

  final List<MonthlyCashFlow> monthlyCashFlow;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = currency.name.toUpperCase();
    final locale = Localizations.localeOf(context).toString();
    final monthFormat = DateFormat.MMM(locale);

    final overallRevenue = monthlyCashFlow.fold<int>(
      0,
      (sum, m) => sum + m.income,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cashFlow,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      l10n.overallRevenue,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatCents(overallRevenue, currencyCode: currencyCode),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Only monthly granularity is supported today, so this is a
              // static label rather than a real dropdown for v1.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(Rounded.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.periodMonthly,
                      style: context.textTheme.bodySmall,
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            height: 180,
            child: _CashFlowChart(
              monthlyCashFlow: monthlyCashFlow,
              currencyCode: currencyCode,
              monthFormat: monthFormat,
              incomeColor: colors.primaryStrong,
              expenseColor: colors.error,
              gridColor: colors.onSurfaceVariant.withValues(alpha: 0.12),
              labelColor: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _compactCurrency(int cents, String currencyCode) {
  final formatter = NumberFormat.compactSimpleCurrency(
    locale: 'en_US',
    name: currencyCode,
  );
  return formatter.format(cents / 100);
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({
    required this.monthlyCashFlow,
    required this.currencyCode,
    required this.monthFormat,
    required this.incomeColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<MonthlyCashFlow> monthlyCashFlow;
  final String currencyCode;
  final DateFormat monthFormat;
  final Color incomeColor;
  final Color expenseColor;
  final Color gridColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    for (var i = 0; i < monthlyCashFlow.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), monthlyCashFlow[i].income / 100));
      expenseSpots.add(FlSpot(i.toDouble(), monthlyCashFlow[i].expense / 100));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          horizontalInterval: null,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) {
                final amountCents = (value * 100).round();
                return Text(
                  _compactCurrency(amountCents, currencyCode),
                  style: TextStyle(fontSize: 11, color: labelColor),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthlyCashFlow.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Text(
                    monthFormat.format(monthlyCashFlow[index].month),
                    style: TextStyle(fontSize: 11, color: labelColor),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final month = monthlyCashFlow[spot.x.toInt()].month;
                final label =
                    '${monthFormat.format(month)} ${DateFormat('yy').format(month)}';
                final amountCents = (spot.y * 100).round();
                return LineTooltipItem(
                  '$label · ${formatCents(amountCents, currencyCode: currencyCode)}',
                  TextStyle(
                    color: spot.bar.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: incomeColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: expenseColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
