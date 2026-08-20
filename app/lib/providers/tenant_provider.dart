import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/tenant.dart';
import 'supabase_provider.dart';

part 'tenant_provider.g.dart';

/// Provides the current tenant context based on the authenticated user's
/// JWT claims (app_metadata.org_id).
@riverpod
Future<Tenant?> currentTenant(Ref ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  final orgId = user.appMetadata['org_id'] as String?;
  if (orgId == null) return null;

  final response = await supabase
      .from('tenants')
      .select()
      .eq('id', orgId)
      .maybeSingle();

  if (response == null) return null;
  return Tenant.fromJson(response);
}

/// Provides the list of tenants the current user belongs to.
@riverpod
Future<List<Tenant>> userTenants(Ref ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  // Query tenant memberships for the current user
  final response = await supabase
      .from('tenant_members')
      .select('tenant:tenants(*)')
      .eq('user_id', user.id);

  return (response as List)
      .map((row) => Tenant.fromJson(row['tenant'] as Map<String, dynamic>))
      .toList();
}
