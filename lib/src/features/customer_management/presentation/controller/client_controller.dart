import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sewsafe_mobile/src/features/customer_management/data/repositories/client_repository.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'client_controller.g.dart';

@riverpod
class ClientController extends _$ClientController {
  @override
  FutureOr<void> build() {
    // Initial/Idle state. We use this controller to manage submission states.
  }

  /// Creates a new client record and updates state accordingly.
  /// Returns [true] if successful, [false] otherwise.
  Future<bool> addClient({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required Map<String, double> measurements,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(clientRepositoryProvider);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('No logged-in tailor found. Please sign in again.');
      }

      final client = Client(
        userId: user.id,
        fullName: fullName,
        phoneNumber: phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
        gender: gender,
        measurements: measurements,
        photoUrl: photoUrl,
      );

      await repository.createClient(client);
    });

    return !state.hasError;
  }
}
