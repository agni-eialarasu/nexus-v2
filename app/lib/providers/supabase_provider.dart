import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provides the Supabase client instance.
@riverpod
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}

/// Provides the Supabase auth instance.
@riverpod
GoTrueClient supabaseAuth(Ref ref) {
  return ref.watch(supabaseProvider).auth;
}
