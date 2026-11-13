import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/rounded.dart';

/// A filled pill painted behind [child], under the item [selectedKey] marks.
/// A new selection stretches it there like a drop of ink: the front edge
/// arrives first, then the back edge catches up. It's only painted, so
/// nothing is laid out again while it moves.
class StretchPill extends StatefulWidget {
  const StretchPill({
    super.key,
    required this.selectedKey,
    required this.color,
    this.stretches = true,
    required this.child,
  });

  /// The selected item's key, on a widget inside [child]; null paints no pill.
  final GlobalKey? selectedKey;
  final Color color;

  /// False: the pill moves to a new selection at once, with no stretch.
  final bool stretches;
  final Widget child;

  @override
  State<StretchPill> createState() => _StretchPillState();
}

class _StretchPillState extends State<StretchPill>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, value: 1);

  /// Where the pill was last painted, so a stretch starts from there even
  /// when the selection changes again mid-way.
  Rect? _painted;
  Rect? _from;

  @override
  void didUpdateWidget(StretchPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedKey == widget.selectedKey) return;
    if (!widget.stretches) {
      _from = null;
      _controller.value = 1;
      return;
    }
    _from = _painted;
    _controller
      ..duration = context.motion(Motion.pillStretch)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The selected item's rect in this widget's coordinates; read while
  /// painting, so it's right even while the items resize.
  Rect? _selectedRect() {
    final item = widget.selectedKey?.currentContext?.findRenderObject();
    final self = context.findRenderObject();
    if (item is! RenderBox || self is! RenderBox || !item.attached) {
      return null;
    }
    return MatrixUtils.transformRect(
      item.getTransformTo(self),
      Offset.zero & item.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StretchPillPainter(
        selectedKey: widget.selectedKey,
        from: _from,
        to: _selectedRect,
        progress: _controller,
        color: widget.color,
        onPaint: (rect) => _painted = rect,
      ),
      child: widget.child,
    );
  }
}

class _StretchPillPainter extends CustomPainter {
  _StretchPillPainter({
    required this.selectedKey,
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
    required this.onPaint,
  }) : super(repaint: progress);

  final GlobalKey? selectedKey;
  final Rect? from;
  final Rect? Function() to;
  final Animation<double> progress;
  final Color color;
  final ValueChanged<Rect> onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final target = to();
    if (target == null) return;
    final rect = _stretched(target);
    onPaint(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(Rounded.pill)),
      Paint()..color = color,
    );
  }

  Rect _stretched(Rect target) {
    final from = this.from;
    final t = progress.value;
    if (from == null || t >= 1) return target;
    const lead = Motion.pillStretchLead;
    const curve = Motion.emphasizedCurve;
    final front = curve.transform((t / lead).clamp(0.0, 1.0));
    final back = curve.transform(((t - lead) / (1 - lead)).clamp(0.0, 1.0));
    final forward = target.left >= from.left;
    return Rect.fromLTRB(
      lerpDouble(from.left, target.left, forward ? back : front)!,
      target.top,
      lerpDouble(from.right, target.right, forward ? front : back)!,
      target.bottom,
    );
  }

  @override
  bool shouldRepaint(_StretchPillPainter oldDelegate) =>
      oldDelegate.selectedKey != selectedKey ||
      oldDelegate.from != from ||
      oldDelegate.color != color;
}
