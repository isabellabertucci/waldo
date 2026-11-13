import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/leather_colors.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/widgets/dashed_border.dart';

/// How each leather looks (DESIGN.md "Wallets").
extension LeatherFinishColors on LeatherFinish {
  /// (top, deep, strap).
  (Color, Color, Color) get colors => switch (this) {
    LeatherFinish.black => LeatherColors.black,
    LeatherFinish.yellow => LeatherColors.yellow,
    LeatherFinish.green => LeatherColors.green,
    LeatherFinish.white => LeatherColors.white,
  };

  bool get isDark => this == LeatherFinish.black;

  /// Text on this leather.
  Color get ink => isDark ? LeatherColors.onDark : LeatherColors.onLight;
  Color get positive =>
      isDark ? LeatherColors.positiveOnDark : LeatherColors.positiveOnLight;
  Color get negative =>
      isDark ? LeatherColors.negativeOnDark : LeatherColors.negativeOnLight;

  /// Hot-stamped lettering's colour: the ink pressed into the leather, so it
  /// reads as the leather's own darker (or lighter) tone. [small] text
  /// keeps more ink, so it stays readable (4.5:1).
  Color debossInk({bool small = false}) =>
      ink.withValues(alpha: small ? Alpha.strong : Alpha.muted);

  /// The light under each stamped letter and the shade over it.
  List<Shadow> get deboss => [
    Shadow(
      offset: const Offset(0, 1),
      color: isDark
          ? LeatherColors.debossLightOnDark
          : LeatherColors.debossLightOnLight,
    ),
    Shadow(
      offset: const Offset(0, -1),
      blurRadius: 1,
      color: isDark
          ? LeatherColors.debossShadeOnDark
          : LeatherColors.debossShadeOnLight,
    ),
  ];

  /// An amount on this leather: gains and losses coloured whole, zero in ink.
  Color amountColor(int cents) => switch (cents) {
    > 0 => positive,
    < 0 => negative,
    _ => ink,
  };
}

/// The leather wallet: a 150° gradient with the leather's grain, a dashed
/// stitch in from the edge, and a strap with a metal button on the right.
/// [child] sits inside the stitch, clear of the strap.
class LeatherWallet extends StatelessWidget {
  const LeatherWallet({
    super.key,
    required this.finish,
    required this.child,
    this.height = ComponentSize.wallet,
  });

  final LeatherFinish finish;
  final Widget child;
  final double height;

  // 150° in CSS: from the top left, slightly past straight down.
  static const _begin = Alignment(-0.5, -1);
  static const _end = Alignment(0.5, 1);

  @override
  Widget build(BuildContext context) {
    final (top, deep, strap) = finish.colors;
    final shape = BorderRadius.circular(Rounded.lg);

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: shape,
              child: DecoratedBox(
                decoration: const BoxDecoration().copyWith(
                  gradient: LinearGradient(
                    begin: _begin,
                    end: _end,
                    colors: [top, deep],
                  ),
                  // The grain alone - light and dark specks, no colour - so
                  // one texture works on every leather.
                  image: const DecorationImage(
                    image: AssetImage('assets/textures/leather-grain.png'),
                    fit: BoxFit.cover,
                    opacity: _grainOpacity,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Stitch.walletInset),
                  child: DashedBorder(
                    radius: Rounded.lg - Stitch.walletInset,
                    color: finish.isDark
                        ? LeatherColors.stitchOnDark
                        : LeatherColors.stitchOnLight,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
          // The strap, centred on the wallet's height and poking past its
          // right edge.
          Positioned(
            right: -ComponentSize.walletStrapOverhang,
            top: (height - ComponentSize.walletStrap) / 2,
            child: _Strap(color: strap),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _contentInset,
                _contentInset,
                ComponentSize.walletStrapRoom,
                _contentInset,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: finish.ink),
                child: IconTheme.merge(
                  data: IconThemeData(color: finish.ink),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barely there: the leather reads smooth, the grain only up close.
  static const _grainOpacity = 0.12;

  /// The stitch plus room inside it.
  static const _contentInset = Stitch.walletInset * 2 + Stitch.width * 4;
}

class _Strap extends StatelessWidget {
  const _Strap({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ComponentSize.walletStrap,
      height: ComponentSize.walletStrap,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.only(
        start:
            (ComponentSize.walletStrap - ComponentSize.walletRivet) / 2 -
            ComponentSize.walletStrapOverhang,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadiusDirectional.horizontal(
          start: Radius.circular(Rounded.sm),
        ),
        // The same leather's grain, so the strap isn't flat plastic.
        image: const DecorationImage(
          image: AssetImage('assets/textures/leather-grain.png'),
          fit: BoxFit.cover,
          opacity: LeatherWallet._grainOpacity,
        ),
      ),
      child: Container(
        width: ComponentSize.walletRivet,
        height: ComponentSize.walletRivet,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: LeatherColors.rivet,
            stops: [0, 0.55, 1],
          ),
          border: Border.all(
            color: LeatherColors.rivetRim,
            width: ComponentSize.walletRivetRim,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
    );
  }
}

/// A wallet's leather as a list row's thumbnail: the whole [LeatherWallet],
/// drawn at a larger size and scaled down, so the stitch and strap keep its
/// proportions.
class LeatherWalletThumb extends StatelessWidget {
  const LeatherWalletThumb({super.key, required this.finish});

  final LeatherFinish finish;

  @override
  Widget build(BuildContext context) {
    const size = ComponentSize.walletThumb;
    const scale = ComponentSize.walletThumbScale;

    return SizedBox.fromSize(
      size: size,
      child: FittedBox(
        child: SizedBox(
          width: size.width * scale,
          height: size.height * scale,
          child: LeatherWallet(
            finish: finish,
            height: size.height * scale,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
