import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/domain/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // 1. Listen to Authentication State Changes (Reactive!)
  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return AppUser(
        id: user.id,
        email: user.email ?? '',
      );
    });
  }

  // 2. Get Current User directly
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  // 3. Login
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 4. Signup
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 5. Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

// 6. Provide the Repository using Riverpod
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // We use the globally initialized Supabase instance.
  return AuthRepository(Supabase.instance.client);
});

// 7. Provide a Stream of the Auth State directly for the UI & Router to listen to
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});
