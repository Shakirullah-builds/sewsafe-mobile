import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewsafe_mobile/src/features/customer_management/domain/entities/client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientRepository {
  final SupabaseClient _supabase;

  ClientRepository(this._supabase);

  /// Inserts a new client record and their measurements using a two-step relational transaction
  Future<void> createClient(Client client) async {
    // 1. Insert basic metadata into the 'clients' table
    final clientResponse = await _supabase.from('clients').insert({
      'fullName': client.fullName,
      'phoneNumber': client.phoneNumber,
      'gender': client.gender,
      'userId': client.userId,
    }).select().single();

    final clientId = clientResponse['id'] as String;

    // 2. Insert dynamic measurements into the 'measurements' table
    await _supabase.from('measurements').insert({
      'clientsId': clientId,
      'measurementData': {
        ...client.measurements,
        if (client.photoUrl != null) '_photo_url': client.photoUrl,
      },
    });
  }

  /// Fetches all client records belonging to the authenticated tailor
  Future<List<Client>> getClients() async {
    // Fetch clients joined with their measurements
    final response = await _supabase
        .from('clients')
        .select('*, measurements(*)')
        .order('createdAt', ascending: false);
    
    final list = response as List<dynamic>;
    return list.map((json) {
      final clientMap = Map<String, dynamic>.from(json as Map);
      
      // Pull measurements list relations
      final measurementsList = json['measurements'] as List<dynamic>? ?? [];
      
      // Extract the measurementData JSON from the latest measurement row
      Map<String, dynamic> measurementsJson = {};
      if (measurementsList.isNotEmpty) {
        final latestMeasurement = measurementsList.first as Map<String, dynamic>;
        measurementsJson = latestMeasurement['measurementData'] as Map<String, dynamic>? ?? {};
      }
      
      clientMap['measurements'] = measurementsJson;
      return Client.fromJson(clientMap);
    }).toList();
  }
}

/// Standard Riverpod Provider for ClientRepository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(Supabase.instance.client);
});
