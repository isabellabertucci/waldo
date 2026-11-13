import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// One choice of a filter grid (DESIGN.md "Filter tiles").
typedef FilterTileData = ({
  IconData icon,
  String label,

  /// How many things it leaves, e.g. "3 wallets".
  String caption,
  bool selected,
  VoidCallback onTap,
});

/// A filter's choices as tiles, three to a row, on the page itself rather
/// than in a sheet: an icon disc, the name and how many it leaves. The
/// chosen one is green and stitched. The wallets list and a wallet's
/// transactions filter the same way.
class FilterTiles extends StatelessWidget {
  const FilterTiles({super.key, required this.tiles});

  final List<FilterTileData> tiles;

  @override
  Widget build(BuildContext context) {
    // One to a row at the largest text sizes, so the names stay whole.
    final perRow = DynamicTypeScaler.isAccessibilitySize(context) ? 1 : 3;

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += perRow) ...[
          if (i > 0) const SizedBox(height: Spacing.xs),
          // Tiles in a row share the tallest one's height.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + perRow; j++) ...[
                  if (j > i) const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: j < tiles.length
                        ? _FilterTile(data: tiles[j])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({required this.data});

  final FilterTileData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shape = BorderRadius.circular(Rounded.md);
    final selected = data.selected;

    final tile = Material(
      color: selected
          ? colors.accent.withValues(alpha: Alpha.stitch)
          : colors.card,
      borderRadius: shape,
      child: InkWell(
        borderRadius: shape,
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.component + Spacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: BadgeSize.md,
                height: BadgeSize.md,
                decoration: BoxDecoration(
                  color: selected ? colors.accent : colors.sheet,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: IconSize.md,
                  color: selected ? colors.onAccent : colors.ink,
                ),
              ),
              const SizedBox(height: Spacing.component),
              Text(data.label, style: context.bodyStrong),
              Text(
                data.caption,
                style: context.label.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(button: true, selected: selected, child: tile);
  }
}
