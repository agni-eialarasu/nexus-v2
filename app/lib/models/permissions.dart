/// View mode determines what data scope a user sees on a page.
enum ViewMode {
  /// Only own data (assigned to me).
  own,

  /// Own data + direct reports' data.
  team,

  /// All data within the tenant.
  global,
}

/// Permission for a single page/feature.
class PagePermission {
  const PagePermission({
    this.view = false,
    this.edit = false,
    this.viewMode = ViewMode.own,
  });

  final bool view;
  final bool edit;
  final ViewMode viewMode;

  factory PagePermission.fromJson(Map<String, dynamic> json) {
    return PagePermission(
      view: json['view'] as bool? ?? false,
      edit: json['edit'] as bool? ?? false,
      viewMode: _parseViewMode(json['viewMode'] as String?),
    );
  }

  static ViewMode _parseViewMode(String? value) {
    switch (value) {
      case 'team':
        return ViewMode.team;
      case 'global':
        return ViewMode.global;
      default:
        return ViewMode.own;
    }
  }

  /// Full access permission.
  static const PagePermission full = PagePermission(
    view: true,
    edit: true,
    viewMode: ViewMode.global,
  );
}

/// Resolved permissions for the current user.
class UserPermissions {
  const UserPermissions({required this.pages, this.isOrgAdmin = false});

  final Map<String, PagePermission> pages;
  final bool isOrgAdmin;

  /// No access at all.
  factory UserPermissions.none() {
    return const UserPermissions(pages: {});
  }

  /// Full access (org admin).
  factory UserPermissions.fullAccess() {
    return const UserPermissions(pages: {}, isOrgAdmin: true);
  }

  /// Resolve permissions from role + user overrides.
  factory UserPermissions.resolve({
    Map<String, dynamic>? rolePermissions,
    Map<String, dynamic>? userOverrides,
  }) {
    final pages = <String, PagePermission>{};

    // Start with role permissions
    if (rolePermissions != null && rolePermissions['pages'] is Map) {
      final rolePages = rolePermissions['pages'] as Map<String, dynamic>;
      for (final entry in rolePages.entries) {
        if (entry.value is Map<String, dynamic>) {
          pages[entry.key] = PagePermission.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      }
    }

    // Apply user-level overrides (user permissions win)
    if (userOverrides != null && userOverrides['pages'] is Map) {
      final userPages = userOverrides['pages'] as Map<String, dynamic>;
      for (final entry in userPages.entries) {
        if (entry.value is Map<String, dynamic>) {
          pages[entry.key] = PagePermission.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      }
    }

    return UserPermissions(pages: pages);
  }

  /// Check if user can view a specific page.
  bool hasPageAccess(String pageId) {
    if (isOrgAdmin) return true;
    return pages[pageId]?.view ?? false;
  }

  /// Check if user can edit on a specific page.
  bool hasPageEdit(String pageId) {
    if (isOrgAdmin) return true;
    return pages[pageId]?.edit ?? false;
  }

  /// Get the view mode for a specific page.
  ViewMode getViewMode(String pageId) {
    if (isOrgAdmin) return ViewMode.global;
    return pages[pageId]?.viewMode ?? ViewMode.own;
  }
}
