import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sewsafe_mobile/src/features/auth/backend/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Nothing to do when building the controller. We just want to expose the methods.
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signup(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
    });
  }

  Future<void> resendVerification(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.resendVerificationEmail(email: email);
    });
  }

  Future<void> verifySignUpOTP(String email, String token) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendPasswordResetEmail(email: email);
    });
  }

  Future<void> verifyPasswordResetOTP(String email, String token) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
    });
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.updateUserPassword(newPassword: newPassword);
    });
  }

  Future<void> checkSessionStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.refreshSession();
    });
  }
}
