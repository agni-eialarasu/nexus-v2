import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';

/// App shell with responsive sidebar navigation.
///
/// Layout adapts to screen width:
/// - Small (< 600px): Bottom navigation bar
/// - Medium (600-1024px): Collapsed rail navigation
/// - Large (> 1024px): Expanded sidebar navigation
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < NexusTokens.breakpointSm) {
      return _SmallLayout(child: child);
    } else if (width < NexusTokens.breakpointMd) {
      return _MediumLayout(child: child);
    } else {
      return _LargeLayout(child: child);
    }
  }
}

/// Mobile layout with bottom navigation.
class _SmallLayout extends StatelessWidget {
  const _SmallLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // TODO: Navigate based on index
        },
      ),
    );
  }
}

/// Tablet layout with navigation rail.
class _MediumLayout extends StatelessWidget {
  const _MediumLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder),
                label: Text('Projects'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // TODO: Navigate based on index
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Desktop layout with full sidebar.
class _LargeLayout extends StatelessWidget {
  const _LargeLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: _DesktopSidebar(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Logo / Org Name
          Padding(
            padding: const EdgeInsets.all(NexusTokens.space16),
            child: Row(
              children: [
                Icon(Icons.hub, color: NexusTokens.accent, size: 28),
                const SizedBox(width: NexusTokens.space8),
                Text(
                  'Nexus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Navigation items
          // TODO: Generate from RBAC-filtered navigation list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: NexusTokens.space8,
                vertical: NexusTokens.space4,
              ),
              children: const [
                _NavItem(icon: Icons.dashboard, label: 'Dashboard', selected: true),
                _NavItem(icon: Icons.folder, label: 'Projects'),
                _NavItem(icon: Icons.view_column, label: 'Portfolios'),
                _NavItem(icon: Icons.track_changes, label: 'OKRs'),
                _NavItem(icon: Icons.attach_money, label: 'Financials'),
                _NavItem(icon: Icons.timeline, label: 'Roadmaps'),
                _NavItem(icon: Icons.warning, label: 'RAID'),
                _NavItem(icon: Icons.access_time, label: 'Timesheets'),
                _NavItem(icon: Icons.people, label: 'Team'),
              ],
            ),
          ),
          // User / Settings
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(NexusTokens.space8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Settings'),
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexusTokens.radiusSm),
              ),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? NexusTokens.accent : NexusTokens.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? NexusTokens.accent : NexusTokens.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: selected,
      selectedTileColor: NexusTokens.accentLight.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexusTokens.radiusSm),
      ),
      dense: true,
      onTap: () {
        // TODO: Navigate
      },
    );
  }
}
