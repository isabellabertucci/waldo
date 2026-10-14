import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_theme.dart';

/// The metal finish a wallet card is drawn in - cycles by the wallet's
/// position in its list (1st platinum, 2nd gold, 3rd bronze, repeating),
/// so the same wallet always gets the same finish regardless of how many
/// others are around it.
///
/// Each finish carries both its light-mode texture photo and its dark-mode
/// gradient (a true dark metal - gunmetal/dark brass/dark copper - rather
/// than the same light photo dimmed down, which read as a flat gray smudge
/// against the dark background).
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

  /// (edge, shine) - the edge tone sits at both ends of the diagonal, the
  /// shine tone sweeps through the middle. The real light-mode photos have
  /// their highlight as the brightest point, not the darkest, so the
  /// gradient's middle stop must be the LIGHTER of the two colors here -
  /// dark at the edges, light in the middle - or the "shine" reads as a
  /// smudge instead of a highlight.
  final (Color, Color) darkColors;

  factory WalletCardFinish.fromIndex(int index) =>
      values[index % values.length];
}

const _brushedLinesOverlayAsset =
    'assets/textures/cards/brushed-lines-overlay.png';

/// The shared background for every wallet card - the finish's own metal
/// base plus the same brushed-lines overlay on top (its opacity is already
/// baked into the asset). Used everywhere a wallet card is drawn: the
/// Wallets screen's stack and the card peeking out of the leather wallet
/// on the dashboard.
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

/// The ink color for text/icons sitting on a [WalletCardBackground] - the
/// app's fixed dark-ink/cream-on-dark pair stays the same across themes, so
/// this picks the side that's actually legible against the finish, which
/// flips with brightness since the finish itself does (light metal in light
/// mode, dark metal in dark mode) even though neither token moves.
Color walletCardInkColor(BuildContext context, {required double alpha}) {
  final colors = context.appColors;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return (isDark ? colors.onLeather : colors.leather).withValues(alpha: alpha);
}

/// A subtle debossed/engraved look for text sitting on a
/// [WalletCardBackground] - a light highlight just below (where light would
/// catch the bottom edge of a groove stamped into the metal) and a dark
/// shadow just above (where the groove blocks it) - so the name and balance
/// read as part of the card's material instead of a flat label pasted on
/// top of it. The same two shadow colors work on both the light and dark
/// finishes, since this models light hitting the surface, not the ink
/// color (which [walletCardInkColor] already handles separately).
const walletCardTextShadow = [
  Shadow(offset: Offset(0, 1), color: Color(0x8CFFFFFF)), // one-off
  Shadow(
    offset: Offset(0, -1),
    blurRadius: 1,
    color: Color(0x4D000000),
  ), // one-off
];

/// The negative-balance color for text on a [WalletCardBackground].
///
/// Light mode keeps the theme's own deep, saturated error red-orange - it
/// already reads fine against the bright photo. Dark mode lightens that
/// same hue further toward white/cream rather than using the theme's own
/// (already lighter, but still fairly saturated) dark-mode error orange,
/// which still read as too low-contrast against the dark metal card.
Color walletCardNegativeColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (!isDark) return AppColors.light.error;

  final hsl = HSLColor.fromColor(AppColors.dark.error);
  return hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
}
