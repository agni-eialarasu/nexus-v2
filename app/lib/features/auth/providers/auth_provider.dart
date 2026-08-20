import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/supabase_provider.dart';

part 'auth_provider.g.dart';

/// Watches the Supabase auth state (login/logout/token refresh).
///
/// Returns the current [Session] or null if not authenticated.
@riverpod
Stream<Session?> authState(Ref ref) {
  final auth = ref.watch(supabaseAuthProvider);

  return auth.onAuthStateChange.map((event) => event.session);
}

/// Provides the current authenticated user (Supabase User object).
@riverpod
User? currentUser(Ref ref) {
  final auth = ref.watch(supabaseAuthProvider);
  return auth.currentUser;
}

/// Authentication actions (login, register, logout, etc.)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  /// Sign in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(supabaseAuthProvider);
      await auth.signInWithPassword(email: email, password: password);
    });
  }

  /// Register a new user with email and password.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(supabaseAuthProvider);
      await auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
        },
      );
    });
  }

  /// Sign in with Google OAuth via Supabase.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(supabaseAuthProvider);
      await auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
    });
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = ref.read(supabaseAuthProvider);
      await auth.signOut();
    });
  }
}
