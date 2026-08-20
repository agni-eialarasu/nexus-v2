import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';

/// Main dashboard screen — shows overview of projects, OKRs, and key metrics.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > NexusTokens.breakpointMd ? 4 : 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(NexusTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: NexusTokens.space4),
                  Text(
                    'Project portfolio overview',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NexusTokens.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: NexusTokens.space24,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: NexusTokens.space16,
                mainAxisSpacing: NexusTokens.space16,
                childAspectRatio: 2.0,
              ),
              delegate: SliverChildListDelegate([
                const _StatCard(
                  title: 'Active Projects',
                  value: '—',
                  icon: Icons.folder,
                  color: NexusTokens.accent,
                ),
                const _StatCard(
                  title: 'On Track',
                  value: '—',
                  icon: Icons.check_circle,
                  color: NexusTokens.success,
                ),
                const _StatCard(
                  title: 'At Risk',
                  value: '—',
                  icon: Icons.warning,
                  color: NexusTokens.warning,
                ),
                const _StatCard(
                  title: 'Overdue',
                  value: '—',
                  icon: Icons.error,
                  color: NexusTokens.danger,
                ),
              ]),
            ),
          ),

          // Placeholder for charts and lists
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(NexusTokens.space24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(NexusTokens.space32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 48,
                          color: NexusTokens.textMuted,
                        ),
                        const SizedBox(height: NexusTokens.space16),
                        Text(
                          'Dashboard widgets will appear here',
                          style: TextStyle(color: NexusTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: NexusTokens.space8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NexusTokens.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexusTokens.space8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
