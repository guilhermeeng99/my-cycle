import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: _FloatingNav(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final items = <_NavItem>[
      _NavItem(icon: BloomIcons.navToday, label: t.nav.today),
      _NavItem(
        icon: BloomIcons.navCalendar,
        selectedIcon: BloomIcons.navCalendarFilled,
        label: t.nav.calendar,
      ),
      _NavItem(icon: BloomIcons.navInsights, label: t.nav.insights),
      _NavItem(icon: BloomIcons.navSettings, label: t.nav.settings),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BloomSpacing.s16,
          0,
          BloomSpacing.s16,
          BloomSpacing.s12,
        ),
        child: ClipRRect(
          borderRadius: BloomRadii.pillShape,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.82),
                borderRadius: BloomRadii.pillShape,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BloomSpacing.s8,
                  vertical: BloomSpacing.s8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    for (var i = 0; i < items.length; i++)
                      _NavTab(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    return Semantics(
      selected: selected,
      label: item.label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s12,
            vertical: BloomSpacing.s8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: color,
              ),
              const SizedBox(height: BloomSpacing.s4),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
