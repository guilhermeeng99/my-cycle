import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Single tile in a [BloomCategoryGrid].
class BloomCategoryTile {
  const BloomCategoryTile({
    required this.icon,
    required this.label,
    required this.tone,
    this.onTap,
  });

  /// Icon rendered inside the rounded square. White-on-color in this layout.
  final IconData icon;

  /// Short label rendered below the rounded square.
  final String label;

  /// Brand color of the tile — used for both the icon background and a
  /// faint matching glow if depth is added later.
  final Color tone;

  /// Optional tap target. Tiles without a callback are static decoration.
  final VoidCallback? onTap;
}

/// Grid of colorful rounded-square category icons + labels — the FocusPomo
/// "Welcome" layout (6 icons in a 2-row × 3-column arrangement).
///
/// Used for onboarding intros and any "pick a category" screen. Tiles are
/// equal width; the parent should give enough horizontal room for the
/// requested column count.
///
/// Example:
/// ```dart
/// BloomCategoryGrid(
///   columns: 3,
///   tiles: [
///     BloomCategoryTile(icon: BloomIcons.cycle, label: 'Cycle', tone: ...),
///     BloomCategoryTile(icon: BloomIcons.bell,  label: 'Alerts', tone: ...),
///     // ...
///   ],
/// );
/// ```
class BloomCategoryGrid extends StatelessWidget {
  const BloomCategoryGrid({
    required this.tiles,
    this.columns = 3,
    this.tileSize = 72,
    this.spacing = BloomSpacing.s16,
    super.key,
  });

  final List<BloomCategoryTile> tiles;
  final int columns;
  final double tileSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += columns) {
      final end = (i + columns).clamp(0, tiles.length);
      final rowTiles = tiles.sublist(i, end);
      final hasMoreRows = i + columns < tiles.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: hasMoreRows ? spacing : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var j = 0; j < columns; j++)
                if (j < rowTiles.length)
                  Expanded(child: _Tile(tile: rowTiles[j], size: tileSize))
                else
                  Expanded(child: SizedBox(height: tileSize)),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile, required this.size});

  final BloomCategoryTile tile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: tile.tone,
            borderRadius: BorderRadius.circular(BloomRadii.lg),
          ),
          child: Icon(
            tile.icon,
            size: size * 0.4,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: BloomSpacing.s8),
        Text(
          tile.label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (tile.onTap == null) return Center(child: body);
    return GestureDetector(
      onTap: tile.onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(child: body),
    );
  }
}
