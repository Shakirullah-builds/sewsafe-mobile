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
        if (client.notes != null) '_notes': client.notes,
        if (client.stylePhotos != null) '_style_photos': client.stylePhotos,
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
      
      // Sort measurements in descending order of createdAt in Dart to ensure latest is first
      measurementsList.sort((a, b) {
        final aTime = DateTime.parse(a['createdAt'] as String);
        final bTime = DateTime.parse(b['createdAt'] as String);
        return bTime.compareTo(aTime);
      });
      
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

  /// Updates an existing client record and their latest measurements
  Future<void> updateClient(Client client) async {
    // 1. Update basic metadata in 'clients' table
    await _supabase.from('clients').update({
      'fullName': client.fullName,
      'phoneNumber': client.phoneNumber,
      'gender': client.gender,
    }).eq('id', client.id!);

    // 2. Fetch the latest measurement row for this client to get its ID
    final measurementsResponse = await _supabase
        .from('measurements')
        .select('id')
        .eq('clientsId', client.id!)
        .order('createdAt', ascending: false)
        .limit(1);

    if (measurementsResponse.isNotEmpty) {
      final latestId = measurementsResponse.first['id'];
      // Update that specific measurement row
      await _supabase.from('measurements').update({
        'measurementData': {
          ...client.measurements,
          if (client.photoUrl != null) '_photo_url': client.photoUrl,
          if (client.notes != null) '_notes': client.notes,
          if (client.stylePhotos != null) '_style_photos': client.stylePhotos,
        },
      }).eq('id', latestId);
    } else {
      // Fallback: If no measurement row exists, insert one
      await _supabase.from('measurements').insert({
        'clientsId': client.id!,
        'measurementData': {
          ...client.measurements,
          if (client.photoUrl != null) '_photo_url': client.photoUrl,
          if (client.notes != null) '_notes': client.notes,
          if (client.stylePhotos != null) '_style_photos': client.stylePhotos,
        },
      });
    }
  }
}

/// Standard Riverpod Provider for ClientRepository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(Supabase.instance.client);
});

