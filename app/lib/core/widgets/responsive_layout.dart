import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Responsive layout builder that provides different widgets
/// based on screen width breakpoints.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   small: MobileView(),
///   medium: TabletView(),
///   large: DesktopView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.small,
    this.medium,
    this.large,
    super.key,
  });

  /// Widget for small screens (< 600px).
  final Widget small;

  /// Widget for medium screens (600–1024px). Falls back to [small].
  final Widget? medium;

  /// Widget for large screens (> 1024px). Falls back to [medium] or [small].
  final Widget? large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= NexusTokens.breakpointMd) {
          return large ?? medium ?? small;
        } else if (constraints.maxWidth >= NexusTokens.breakpointSm) {
          return medium ?? small;
        }
        return small;
      },
    );
  }

  /// Returns the current breakpoint category.
  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= NexusTokens.breakpointMd) return ScreenSize.large;
    if (width >= NexusTokens.breakpointSm) return ScreenSize.medium;
    return ScreenSize.small;
  }
}

/// Screen size categories for responsive design.
enum ScreenSize {
  small,  // < 600px (phone)
  medium, // 600–1024px (tablet)
  large,  // > 1024px (desktop)
}
