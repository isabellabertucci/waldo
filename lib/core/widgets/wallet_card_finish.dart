import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';

/// A wallet card's metal finish, picked by its position in the list
/// (platinum, gold, bronze, repeating). Light mode uses a photo, dark mode a gradient.
enum WalletCardFinish {
  platinum(
    textureAsset: 'assets/textures/cards/metal-silver.png',
    darkColors: (Color(0xFF1C1E21), Color(0xFF6E7378)), // one-off
  ),
  gold(
    textureAsset: 'assets/textures/cards/metal-champagne.png',
    darkColors: (Color(0xFF241A0E), Color(0xFF8C6A3C)), // one-off
  ),
  bronze(
    textureAsset: 'assets/textures/cards/metal-rose.png',
    darkColors: (Color(0xFF241310), Color(0xFF8A5244)), // one-off
  );

  const WalletCardFinish({
    required this.textureAsset,
    required this.darkColors,
  });

  final String textureAsset;

  /// (edge, shine): the shine is the lighter color, in the middle of the gradient.
  final (Color, Color) darkColors;

  factory WalletCardFinish.fromIndex(int index) =>
      values[index % values.length];
}

const _brushedLinesOverlayAsset =
    'assets/textures/cards/brushed-lines-overlay.png';

/// A wallet card's background: the finish plus the brushed-lines overlay.
class WalletCardBackground extends StatelessWidget {
  const WalletCardBackground({super.key, required this.finish});

  final WalletCardFinish finish;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (edge, shine) = finish.darkColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isDark)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [edge, shine, edge],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          )
        else
          Image.asset(finish.textureAsset, fit: BoxFit.cover),
        Image.asset(_brushedLinesOverlayAsset, fit: BoxFit.cover),
      ],
    );
  }
}

/// The ink color for text on a [WalletCardBackground], legible on its finish.
Color walletCardInkColor(BuildContext context, {required double alpha}) {
  final colors = context.appColors;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return (isDark ? colors.onLeather : colors.leather).withValues(alpha: alpha);
}

/// An engraved look for text on a [WalletCardBackground]: a highlight below
/// and a shadow above.
const walletCardTextShadow = [
  Shadow(offset: Offset(0, 1), color: Color(0x8CFFFFFF)), // one-off
  Shadow(
    offset: Offset(0, -1),
    blurRadius: 1,
    color: Color(0x4D000000),
  ), // one-off
];

/// How much lighter than dark-mode `error` a negative balance is on the dark
/// metal, where plain `error` drops to about 1.7:1 on the finish's shine.
const _negativeOnMetalLift = 0.18; // one-off: see DESIGN.md Known Gaps

/// The negative-balance color for text on a [WalletCardBackground]; lighter in
/// dark mode so it stays readable on the dark metal.
Color walletCardNegativeColor(BuildContext context) {
  final error = context.appColors.error;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (!isDark) return error;

  final hsl = HSLColor.fromColor(error);
  return hsl
      .withLightness((hsl.lightness + _negativeOnMetalLift).clamp(0.0, 1.0))
      .toColor();
}
