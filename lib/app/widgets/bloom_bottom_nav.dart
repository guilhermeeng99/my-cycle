import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Hosts the four primary tabs once the user is authenticated and paired.
///
/// Uses [StatefulNavigationShell] so each branch keeps its own navigation
/// stack — switching tabs preserves scroll position and pushed routes.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const _NavIcon(FontAwesomeIcons.seedling),
            selectedIcon: const _NavIcon(
              FontAwesomeIcons.seedling,
              filled: true,
            ),
            label: t.nav.today,
          ),
          NavigationDestination(
            icon: const _NavIcon(FontAwesomeIcons.calendarDays),
            selectedIcon: const _NavIcon(
              FontAwesomeIcons.solidCalendarDays,
              filled: true,
            ),
            label: t.nav.calendar,
          ),
          NavigationDestination(
            icon: const _NavIcon(FontAwesomeIcons.chartSimple),
            selectedIcon: const _NavIcon(
              FontAwesomeIcons.chartSimple,
              filled: true,
            ),
            label: t.nav.insights,
          ),
          NavigationDestination(
            icon: const _NavIcon(FontAwesomeIcons.gear),
            selectedIcon: const _NavIcon(
              FontAwesomeIcons.gear,
              filled: true,
            ),
            label: t.nav.settings,
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon, {this.filled = false});
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = filled
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BloomSpacing.s4),
      child: Icon(icon, size: 22, color: color),
    );
  }
}
