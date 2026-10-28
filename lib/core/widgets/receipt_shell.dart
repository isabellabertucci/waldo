import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/theme/app_theme.dart';

/// A horizontal dashed rule, matching the wallet card's stitch.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, required this.color, this.thick = false});

  final Color color;
  final bool thick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thick ? 2 : 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color.withValues(alpha: thick ? 0.35 : 0.2),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  // Whole dash+gap units, centered, so both ends are a full dash.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final (:dash, :gap) = Stitch.receipt;
    final unit = dash + gap;
    final count = (size.width / unit).floor();
    if (count < 1) return;
    final usedWidth = count * unit - gap;
    var x = (size.width - usedWidth) / 2;
    for (var i = 0; i < count; i++) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dash, size.height / 2),
        paint,
      );
      x += unit;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// A dotted leader between a label and its value, like a printed receipt.
class DottedLeader extends StatelessWidget {
  const DottedLeader({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.receiptLeader,
      child: CustomPaint(painter: _DottedLinePainter(color: color)),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const dotSpacing = 4.0;
    const dotRadius = 0.75;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawCircle(Offset(x, size.height / 2), dotRadius, paint);
      x += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// One label/value line with a dotted leader filling the gap between them,
/// like an itemized receipt row.
class ReceiptRow extends StatelessWidget {
  const ReceiptRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    this.large = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    // The receipt's own print scale: lines, bold lines, the total.
    final style =
        (large
                ? context.receiptTotal
                : bold
                ? context.receiptLineBold
                : context.receiptLine)
            .copyWith(color: color);

    // Nudged down by the text's descent, so the dots sit on the baseline.
    final descent = style.fontSize! * 0.22;

    final leader = Padding(
      padding: EdgeInsets.only(top: descent),
      child: DottedLeader(color: color.withValues(alpha: Alpha.stitch)),
    );

    // At accessibility sizes the label gets its own line and the dots lead
    // to the value under it, so no category is cut.
    if (DynamicTypeScaler.isAccessibilitySize(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WholeWordsText(label, style: style),
          LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                Expanded(child: leader),
                const SizedBox(width: ComponentSize.receiptLeaderGap),
                // A whole value shrinks rather than overflowing the line.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth - ComponentSize.receiptLeaderGap,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, maxLines: 1, style: style),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // The dots run under the label, which covers them in the paper's colour:
    // a long label is cut with "…" and the value always shows whole.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                // Clipped, so the first dot's edge can't peek out before the label.
                child: ClipRect(
                  // Full width: Center alone would let the dots shrink to nothing.
                  child: Center(
                    child: SizedBox(width: double.infinity, child: leader),
                  ),
                ),
              ),
              ColoredBox(
                color: context.appColors.surface,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: ComponentSize.receiptLeaderGap,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ComponentSize.receiptLeaderGap),
        Text(value, maxLines: 1, style: style),
      ],
    );
  }
}

/// Decorative, non-scannable barcode - purely a visual nod to "this is a
/// receipt", the same fixed bar pattern every time.
class Barcode extends StatelessWidget {
  const Barcode({super.key, required this.color});

  final Color color;

  static const _widths = [
    2, 1, 1, 1, 1, 1, 2, 3, 1, 2, 3, 1, 3, 1, 1, 1, //
    1, 1, 1, 1, 1, 3, 1, 1, 2, 3, 1, 1, 1, 1, 3, 1, 3, 3,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.barcodeHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final width in _widths) ...[
            Container(width: width.toDouble(), color: color),
            const SizedBox(width: ComponentSize.barcodeBarGap),
          ],
        ],
      ),
    );
  }
}

/// Clips a torn/pinked paper edge along the bottom of a receipt-style card.
class ReceiptZigzagClipper extends CustomClipper<Path> {
  const ReceiptZigzagClipper();

  static const _toothWidth = 15.0;
  static const _toothDepth = 8.0;

  @override
  Path getClip(Size size) {
    final teeth = (size.width / _toothWidth).round();
    final toothWidth = size.width / teeth;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);

    for (var i = 1; i <= teeth; i++) {
      final x = size.width - i * toothWidth;
      final y = i.isOdd ? size.height - _toothDepth : size.height;
      path.lineTo(x, y);
    }

    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
