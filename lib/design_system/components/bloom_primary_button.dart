import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Primary CTA button — solid terracotta pill, FocusPomo-style.
///
/// No gradient, no shadow — depth comes from the color contrast against
/// the warm bege scaffold. The button always stretches to the available
/// width (`minWidth: double.infinity`) so it sits comfortably inside a
/// padded column.
///
/// Example:
/// ```dart
/// BloomPrimaryButton(
///   label: 'Next',
///   onPressed: () => cubit.advance(),
/// );
/// ```
class BloomPrimaryButton extends StatelessWidget {
  const BloomPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null || loading;
    final base = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

    return Material(
      borderRadius: BloomRadii.button,
      clipBehavior: Clip.antiAlias,
      color: disabled ? base.withValues(alpha: 0.5) : base,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s24,
            vertical: BloomSpacing.s20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              else if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: BloomSpacing.s8),
              ],
              if (!loading)
                Text(
                  label,
                  style: BloomTypography.body.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary CTA button — cream surface, brown ink, pebble outline.
class BloomSecondaryButton extends StatelessWidget {
  const BloomSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BloomRadii.button,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BloomRadii.button,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s24,
            vertical: BloomSpacing.s20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: theme.colorScheme.onSurface),
                const SizedBox(width: BloomSpacing.s8),
              ],
              Text(
                label,
                style: BloomTypography.body.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
