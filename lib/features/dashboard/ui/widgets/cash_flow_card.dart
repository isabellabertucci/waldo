import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/transactions_x.dart';

import '../../models/dashboard_data.dart';
import 'month_intro_claim.dart';

/// One series (income or expense) at a time; exact values are in the tooltip.
/// The line draws itself in the first time Home shows a month, then its end
/// point pops in with the month's total over it.
class CashFlowCard extends ConsumerStatefulWidget {
  const CashFlowCard({
    super.key,
    required this.month,
    required this.monthlyCashFlow,
    required this.currency,
    required this.isBalanceHidden,
  });

  /// The month Home shows: the line's last point.
  final DateTime month;
  final List<MonthlyCashFlow> monthlyCashFlow;
  final Currency currency;

  /// Turns off the tap-to-see-amount tooltip; the line itself stays.
  final bool isBalanceHidden;

  @override
  ConsumerState<CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends ConsumerState<CashFlowCard>
    with MonthIntroClaim, TickerProviderStateMixin {
  TransactionType _selectedType = TransactionType.expense;

  /// The line drawing in, its end point popping, then the month's total
  /// rising in; all at rest (1) unless a month is playing its intro.
  late final AnimationController _draw;
  late final CurvedAnimation _drawn;
  late final AnimationController _point;
  late final AnimationController _label;

  /// The label waits [Motion.chartLabelDelay] after the point pops.
  late final CurvedAnimation _labelIn;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(
      vsync: this,
      duration: Motion.chartDraw,
      value: 1,
    )..addStatusListener(_onDrawn);
    _drawn = CurvedAnimation(parent: _draw, curve: Motion.emphasizedCurve);
    _point = AnimationController.unbounded(vsync: this, value: 1);
    _label = AnimationController(
      vsync: this,
      duration: Motion.chartLabelDelay + Motion.chartLabel,
      value: 1,
    );
    _labelIn = CurvedAnimation(
      parent: _label,
      curve: Interval(
        Motion.chartLabelDelay.inMicroseconds / _label.duration!.inMicroseconds,
        1,
      ),
    );
    _claimDraw();
  }

  @override
  void didUpdateWidget(CashFlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) _claimDraw();
  }

  void _claimDraw() {
    if (!claimMonthIntro(MonthIntro.cashFlowDraw, widget.month)) return;
    _point.value = 0;
    _label.value = 0;
    _draw.forward(from: 0);
  }

  void _onDrawn(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _point
        .animateWith(SpringSimulation(Motion.wobbly, 0, 1, 0))
        // A spring stops within a hair of rest; end exactly at full size.
        .then((_) => _point.value = 1);
    _label.forward(from: 0);
  }

  @override
  void dispose() {
    _drawn.dispose();
    _draw.dispose();
    _point.dispose();
    _labelIn.dispose();
    _label.dispose();
    super.dispose();
  }

  void _selectType(TransactionType type) {
    if (type == _selectedType) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedType = type);
  }

  @override
  Widget build(BuildContext context) {
    // With reduce motion on, the line and its end point are simply there.
    final still = context.reduceMotion;
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
                _SeriesToggle(selected: _selectedType, onChanged: _selectType),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            height: ComponentSize.chartHeight,
            // A new month draws its own line, rather than reshaping the last.
            child: _CashFlowChart(
              key: ValueKey(widget.month),
              draw: still ? kAlwaysCompleteAnimation : _drawn,
              point: still ? kAlwaysCompleteAnimation : _point,
              label: still ? kAlwaysCompleteAnimation : _labelIn,
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
      // The top and bottom margin is inside each segment's touch.
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      // Segmented controls stop growing where bars do, as on iOS.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: DynamicTypeScaler.barMaxScale,
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
        // Taps on the track's margin count too: a 48px-tall touch.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
          child: AnimatedContainer(
            duration: Motion.toggle,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.component,
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
      ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({
    super.key,
    required this.draw,
    required this.point,
    required this.label,
    required this.monthlyCashFlow,
    required this.currencyCode,
    required this.locale,
    required this.monthFormat,
    required this.selectedType,
    required this.seriesColor,
    required this.labelColor,
    required this.isBalanceHidden,
  });

  /// How much of the line is drawn, left to right.
  final Animation<double> draw;

  /// The end point's size; a spring, so it overshoots before settling.
  final Animation<double> point;

  /// The month's total fading and rising in over the end point.
  final Animation<double> label;
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
    // fl_chart's own range, given explicitly so the end point can be placed
    // on the line.
    final minY = spots.map((s) => s.y).fold(double.infinity, min);
    final maxY = spots.map((s) => s.y).fold(double.negativeInfinity, max);
    final hasEnd = spots.isNotEmpty;

    final labelStyle = context.chartAxis.copyWith(color: labelColor);
    final labels = [
      for (final month in monthlyCashFlow) monthFormat.format(month.month),
    ];

    // One node for screen readers: what the chart shows, then every month's
    // amount (what a touch shows), instead of the bare axis labels.
    final l10n = AppLocalizations.of(context);
    final range = monthlyCashFlow.isEmpty
        ? l10n.cashFlow
        : (selectedType == TransactionType.income
              ? l10n.cashFlowChartIncome
              : l10n.cashFlowChartExpense)(
            DateFormat.yMMM(locale).format(monthlyCashFlow.first.month),
            DateFormat.yMMM(locale).format(monthlyCashFlow.last.month),
          );
    final amounts = isBalanceHidden
        ? l10n.amountsHidden
        : [
            for (final month in monthlyCashFlow)
              '${DateFormat.MMMM(locale).format(month.month)}: '
                  '${formatCents(_valueFor(month), locale: moneyLocale(context), currencyCode: currencyCode)}',
          ].join('; ');

    return Semantics(
      container: true,
      label: range,
      value: amounts,
      excludeSemantics: true,
      child: LayoutBuilder(
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
          final titlesHeight = tallest + Spacing.xs;
          final plotHeight = constraints.maxHeight - titlesHeight;

          final chart = LineChart(
            // Toggling the series reshapes the line, colour and all.
            duration: context.motion(Motion.chartMorph),
            curve: Motion.emphasizedCurve,
            LineChartData(
              minY: hasEnd ? minY : null,
              maxY: hasEnd ? maxY : null,
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
                    reservedSize: titlesHeight,
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
                          color: seriesColor.withValues(alpha: Alpha.line),
                          strokeWidth: ComponentSize.chartGuide,
                          dashArray: const [
                            ComponentSize.chartGuideDash,
                            ComponentSize.chartGuideDash,
                          ],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: ComponentSize.chartDotRadius,
                                color: seriesColor,
                                strokeWidth: ComponentSize.chartDotRing,
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
                      context.bodySmBold.copyWith(color: colors.onPrimary),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  // A flat run of months stays flat, never dipping below it.
                  preventCurveOverShooting: true,
                  color: seriesColor,
                  barWidth: ComponentSize.chartLine,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        seriesColor.withValues(alpha: Alpha.stitch),
                        seriesColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // The line and its shading draw in; the month names don't.
              ClipPath(
                clipper: _DrawClipper(draw: draw, plotHeight: plotHeight),
                child: chart,
              ),
              // On top, but every touch still reaches the chart.
              if (hasEnd)
                Positioned.fill(
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<_EndPoint>(
                      // Blends between series as fl_chart does, so it rides
                      // the line.
                      tween: _EndPointTween(
                        end: _EndPoint(
                          y: spots.last.y,
                          minY: minY,
                          maxY: maxY,
                          color: seriesColor,
                        ),
                      ),
                      duration: context.motion(Motion.chartMorph),
                      curve: Motion.emphasizedCurve,
                      builder: (context, end, _) {
                        final at = Offset(
                          constraints.maxWidth,
                          plotHeight * (1 - end.height),
                        );
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _EndPointPainter(
                                  at: at,
                                  scale: point,
                                  color: end.color,
                                  ring: colors.surface,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomSingleChildLayout(
                                delegate: _EndLabelLayout(at),
                                child: _EndLabel(
                                  text: _endLabel(context),
                                  hidden: isBalanceHidden,
                                  color: end.color,
                                  appear: label,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// The month's total, signed as on the receipt.
  String _endLabel(BuildContext context) {
    final sign = selectedType == TransactionType.income ? '+' : '-';
    final amount = formatCents(
      _valueFor(monthlyCashFlow.last),
      locale: moneyLocale(context),
      currencyCode: currencyCode,
    );
    return '$sign$amount';
  }
}

/// Shows the line and its shading up to [draw] of the way across; the month
/// names below them always show.
class _DrawClipper extends CustomClipper<Path> {
  _DrawClipper({required this.draw, required this.plotHeight})
    : super(reclip: draw);

  final Animation<double> draw;
  final double plotHeight;

  @override
  Path getClip(Size size) {
    // Room around the plot for the line's round ends and the touch tooltip.
    final right = draw.value >= 1 ? size.width * 2 : size.width * draw.value;
    return Path()
      ..addRect(Rect.fromLTRB(-size.width, -size.height, right, plotHeight))
      ..addRect(
        Rect.fromLTRB(-size.width, plotHeight, size.width * 2, size.height * 2),
      );
  }

  @override
  bool shouldReclip(_DrawClipper oldClipper) =>
      oldClipper.draw != draw || oldClipper.plotHeight != plotHeight;
}

/// Where the line ends and in what colour, in the chart's own values, so it
/// blends from series to series exactly as the line does.
class _EndPoint {
  const _EndPoint({
    required this.y,
    required this.minY,
    required this.maxY,
    required this.color,
  });

  final double y;
  final double minY;
  final double maxY;
  final Color color;

  /// How far up the plot it sits: 0 at the bottom, as fl_chart puts a flat
  /// line.
  double get height => maxY == minY ? 0 : (y - minY) / (maxY - minY);

  static _EndPoint lerp(_EndPoint a, _EndPoint b, double t) => _EndPoint(
    y: lerpDouble(a.y, b.y, t)!,
    minY: lerpDouble(a.minY, b.minY, t)!,
    maxY: lerpDouble(a.maxY, b.maxY, t)!,
    color: Color.lerp(a.color, b.color, t)!,
  );
}

class _EndPointTween extends Tween<_EndPoint> {
  _EndPointTween({super.end});

  @override
  _EndPoint lerp(double t) => _EndPoint.lerp(begin!, end!, t);
}

/// The line's last point, drawn like the touch dot.
class _EndPointPainter extends CustomPainter {
  _EndPointPainter({
    required this.at,
    required this.scale,
    required this.color,
    required this.ring,
  }) : super(repaint: scale);

  final Offset at;
  final Animation<double> scale;
  final Color color;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = max(0.0, this.scale.value);
    if (scale == 0) return;
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(scale);
    FlDotCirclePainter(
      radius: ComponentSize.chartDotRadius,
      color: color,
      strokeWidth: ComponentSize.chartDotRing,
      strokeColor: ring,
    ).draw(canvas, const FlSpot(0, 0), Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EndPointPainter oldDelegate) =>
      oldDelegate.at != at ||
      oldDelegate.scale != scale ||
      oldDelegate.color != color ||
      oldDelegate.ring != ring;
}

/// Puts the end label just above the point, its right edge on it; beside it
/// on the left when the point is too near the top for it to fit above.
class _EndLabelLayout extends SingleChildLayoutDelegate {
  _EndLabelLayout(this.at);

  final Offset at;

  static const _gap = ComponentSize.chartDotRadius + ComponentSize.chartDotRing;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final above = at.dy - _gap - childSize.height;
    if (above >= 0) return Offset(max(0, at.dx - childSize.width), above);
    return Offset(
      max(0, at.dx - _gap - childSize.width),
      max(0, at.dy - childSize.height / 2),
    );
  }

  @override
  bool shouldRelayout(_EndLabelLayout oldDelegate) => oldDelegate.at != at;
}

class _EndLabel extends StatelessWidget {
  const _EndLabel({
    required this.text,
    required this.hidden,
    required this.color,
    required this.appear,
  });

  final String text;
  final bool hidden;
  final Color color;

  /// Fades it in as it rises [Motion.chartLabelRise] into place.
  final Animation<double> appear;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appear,
      builder: (context, child) => Opacity(
        opacity: appear.value,
        child: Transform.translate(
          offset: Offset(0, (1 - appear.value) * Motion.chartLabelRise),
          child: child,
        ),
      ),
      // The series' new total fades in over the old one; the eye tucks it
      // away like every other amount.
      child: AnimatedSwitcher(
        duration: context.motion(Motion.chartLabel),
        child: BalanceAmount(
          key: ValueKey(text),
          amount: text,
          hidden: hidden,
          style: context.bodySmBold.copyWith(color: color),
          // Its right edge is pinned to the line's end.
          alignment: AlignmentDirectional.centerEnd,
        ),
      ),
    );
  }
}
