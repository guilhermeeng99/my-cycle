import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

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

    return Material(
      borderRadius: BloomRadii.button,
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              if (disabled) base.withValues(alpha: 0.5) else base,
              if (disabled)
                base.withValues(alpha: 0.4)
              else
                base.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BloomRadii.button,
        ),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.s24,
              vertical: BloomSpacing.s16,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                else if (icon != null) ...<Widget>[
                  Icon(icon, size: 16, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: BloomSpacing.s12),
                ],
                if (!loading)
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s24,
            vertical: BloomSpacing.s16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: theme.colorScheme.onSurface),
                const SizedBox(width: BloomSpacing.s12),
              ],
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
