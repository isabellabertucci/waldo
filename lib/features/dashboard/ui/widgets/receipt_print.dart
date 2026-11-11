import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';

import 'month_intro_claim.dart';

/// The pouch with the month's receipt under it. The receipt prints - it
/// feeds out from under the leather, already printed, as it comes down -
/// the first time Home shows that month this session, and never again for it.
class ReceiptPrint extends ConsumerStatefulWidget {
  const ReceiptPrint({
    super.key,
    required this.month,
    required this.isPaper,
    required this.pouch,
    required this.receipt,
  });

  final DateTime month;

  /// False for the dashed "add your first transaction" box, which isn't
  /// paper; the first transaction then prints the month's receipt.
  final bool isPaper;
  final Widget pouch;
  final Widget receipt;

  @override
  ConsumerState<ReceiptPrint> createState() => _ReceiptPrintState();
}

class _ReceiptPrintState extends ConsumerState<ReceiptPrint>
    with MonthIntroClaim {
  late bool _printing = _claimPrint();

  @override
  void didUpdateWidget(ReceiptPrint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.isPaper != widget.isPaper) {
      _printing = _claimPrint();
    }
  }

  /// True when this month's receipt hasn't printed yet; it then counts as
  /// printed.
  bool _claimPrint() =>
      widget.isPaper && claimMonthIntro(MonthIntro.receiptPrint, widget.month);

  @override
  Widget build(BuildContext context) {
    // A new month or a first receipt starts over; nothing else does.
    final key = ValueKey((widget.month, widget.isPaper));
    // With reduce motion on, the receipt is simply there.
    final printing = _printing && !context.reduceMotion;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.pouch,
        // Clipped at the pouch's lower edge, so the paper feeds out from
        // under the leather rather than sliding over it.
        ClipRect(
          child: widget.receipt
              .animate(key: key, autoPlay: printing, value: printing ? 0 : 1)
              .slideY(
                begin: -1,
                end: 0,
                duration: context.motion(Motion.receiptPrint),
                curve: Motion.receiptPrintCurve,
              ),
        ),
      ],
    );
  }
}
