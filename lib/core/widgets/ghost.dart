import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/pill_button.dart';

/// Empty states (DESIGN.md "Empty states"): a faint ghost of what will be
/// there, then what's missing, why it matters, and maybe the way to start.
/// The ghosts are decoration, so screen readers skip them.

/// How strongly each ghost shows, front to back: they fade away.
const _fades = [1.0, Alpha.muted, Alpha.line];

/// A ghost line of text.
class GhostLine extends StatelessWidget {
  const GhostLine({super.key, this.widthFactor, this.width, this.color});

  /// Of the space it has; or a fixed [width].
  final double? widthFactor;
  final double? width;

  /// `card` on the sheet; `line` on a ghost that is itself `card`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: width,
      height: ComponentSize.ghostLine,
      decoration: BoxDecoration(
        color: color ?? context.appColors.card,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
    );
    if (widthFactor == null) return line;
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: line,
    );
  }
}

/// Three ghost rows, as a list of [leading] things would look: a shape,
/// two lines and an amount, fading away.
class GhostRows extends StatelessWidget {
  const GhostRows({super.key, required this.leading});

  final Widget leading;

  /// A transaction's round badge.
  static Widget disc(BuildContext context) => Container(
    width: BadgeSize.lg,
    height: BadgeSize.lg,
    decoration: BoxDecoration(
      color: context.appColors.card,
      shape: BoxShape.circle,
    ),
  );

  /// A wallet's thumbnail, outlined in a faint stitch.
  static Widget wallet(BuildContext context) => DashedBorder(
    radius: Rounded.sm,
    color: context.appColors.line,
    child: SizedBox.fromSize(size: ComponentSize.walletThumb),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: Column(
        children: [
          for (final (i, fade) in _fades.indexed) ...[
            if (i > 0) Divider(height: 1, color: colors.divider),
            Opacity(
              opacity: fade,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: Spacing.sm),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.xs,
                        children: [
                          GhostLine(widthFactor: ComponentSize.ghostTitle),
                          GhostLine(widthFactor: ComponentSize.ghostSubtitle),
                        ],
                      ),
                    ),
                    const GhostLine(width: ComponentSize.ghostAmount),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Home's stack before the first wallet: three ghost wallets, fading.
class GhostWalletStack extends StatelessWidget {
  const GhostWalletStack({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * ComponentSize.ghostWalletWidth;
          const step = ComponentSize.walletStackStep;
          return SizedBox(
            height: ComponentSize.wallet,
            child: Stack(
              children: [
                // Back to front, so the front one is drawn last.
                for (final (i, fade) in _fades.indexed.toList().reversed)
                  PositionedDirectional(
                    start: step.dx * i,
                    top: step.dy * i,
                    bottom: step.dy * i,
                    width: width,
                    child: Opacity(
                      opacity: fade,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(Rounded.lg),
                        ),
                        padding: const EdgeInsets.all(Spacing.xs),
                        child: DashedBorder(
                          radius: Rounded.md,
                          color: colors.line,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GhostLine(
                                  widthFactor: ComponentSize.ghostTitle,
                                  color: colors.line,
                                ),
                                GhostLine(
                                  widthFactor: ComponentSize.ghostSubtitle,
                                  color: colors.line,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A [ghost], then what's missing ([title]), why it matters ([body]) and,
/// with [actionLabel], the yellow way to start.
class GhostEmptyState extends StatelessWidget {
  const GhostEmptyState({
    super.key,
    required this.ghost,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final Widget ghost;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ghost,
        const SizedBox(height: Spacing.md),
        Text(title, textAlign: TextAlign.center, style: context.titleCard),
        const SizedBox(height: Spacing.xxs),
        Text(
          body,
          textAlign: TextAlign.center,
          style: context.label.copyWith(color: colors.inkMuted),
        ),
        if (actionLabel case final label?) ...[
          const SizedBox(height: Spacing.md),
          Center(
            child: PillButton(label: label, onPressed: onAction),
          ),
        ],
      ],
    );
  }
}

/// A section that shows up later, held by a faint stitched card: its
/// [title] and when it will appear ([body]).
class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DashedBorder(
      radius: Rounded.md,
      color: colors.line,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.xxs,
          children: [
            Text(title, style: context.bodyStrong),
            Text(body, style: context.label.copyWith(color: colors.inkMuted)),
          ],
        ),
      ),
    );
  }
}
