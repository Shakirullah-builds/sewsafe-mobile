import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientRepository {
  final SupabaseClient _supabase;

  ClientRepository(this._supabase);

  /// Inserts a new client record into the 'clients' table
  Future<void> createClient(Client client) async {
    await _supabase.from('clients').insert(client.toJson());
  }

  /// Fetches all client records belonging to the authenticated tailor
  Future<List<Client>> getClients() async {
    final response = await _supabase
        .from('clients')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((json) => Client.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Standard Riverpod Provider for ClientRepository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(Supabase.instance.client);
});
