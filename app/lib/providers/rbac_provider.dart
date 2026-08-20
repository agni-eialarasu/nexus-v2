import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/permissions.dart';
import 'supabase_provider.dart';

part 'rbac_provider.g.dart';

/// Provides the current user's resolved permissions.
///
/// Resolution order:
/// 1. isOrgAdmin → full access
/// 2. TenantRole permissions
/// 3. User-level overrides
@riverpod
Future<UserPermissions> permissions(Ref ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return UserPermissions.none();

  // Fetch user's role and permissions from the database
  final response = await supabase
      .from('users')
      .select('is_org_admin, permissions, tenant_role:tenant_roles(permissions)')
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return UserPermissions.none();

  final isOrgAdmin = response['is_org_admin'] as bool? ?? false;

  // Org admins get full access
  if (isOrgAdmin) return UserPermissions.fullAccess();

  // Resolve from tenant role + user overrides
  final rolePermissions = response['tenant_role']?['permissions'];
  final userPermissions = response['permissions'];

  return UserPermissions.resolve(
    rolePermissions: rolePermissions as Map<String, dynamic>?,
    userOverrides: userPermissions as Map<String, dynamic>?,
  );
}

/// Check if the current user can access a specific page.
@riverpod
bool canAccessPage(Ref ref, String pageId) {
  final perms = ref.watch(permissionsProvider).valueOrNull;
  if (perms == null) return false;
  return perms.hasPageAccess(pageId);
}

/// Check if the current user can edit on a specific page.
@riverpod
bool canEditPage(Ref ref, String pageId) {
  final perms = ref.watch(permissionsProvider).valueOrNull;
  if (perms == null) return false;
  return perms.hasPageEdit(pageId);
}

/// Get the view mode for a specific page.
@riverpod
ViewMode pageViewMode(Ref ref, String pageId) {
  final perms = ref.watch(permissionsProvider).valueOrNull;
  if (perms == null) return ViewMode.own;
  return perms.getViewMode(pageId);
}
