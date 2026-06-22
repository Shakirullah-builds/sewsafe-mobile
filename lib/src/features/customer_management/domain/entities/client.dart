class Client {
  final String? id;
  final String userId;
  final String fullName;
  final String? phoneNumber;
  final String gender;
  final Map<String, double> measurements;
  final String? photoUrl;
  final String? notes;
  final DateTime? createdAt;

  Client({
    this.id,
    required this.userId,
    required this.fullName,
    this.phoneNumber,
    required this.gender,
    required this.measurements,
    this.photoUrl,
    this.notes,
    this.createdAt,
  });

  /// Factory constructor to parse client record from Supabase JSON response
  factory Client.fromJson(Map<String, dynamic> json) {
    final rawMeasurements = json['measurements'] as Map<String, dynamic>? ?? {};
    
    // Extract photo URL and notes from measurements metadata if they exist
    final photoUrl = rawMeasurements['_photo_url'] as String?;
    final notes = rawMeasurements['_notes'] as String?;
    
    // Filter out metadata keys to keep measurements strictly numeric
    final measurementsMap = <String, double>{};
    rawMeasurements.forEach((key, value) {
      if (key != '_photo_url' && key != '_notes' && value is num) {
        measurementsMap[key] = value.toDouble();
      }
    });

    return Client(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String,
      measurements: measurementsMap,
      photoUrl: photoUrl,
      notes: notes,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert Client object to JSON map for database insertion/update
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'measurements': {
        ...measurements,
        if (photoUrl != null) '_photo_url': photoUrl,
        if (notes != null) '_notes': notes,
      },
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  /// Create a copy of Client with modified attributes
  Client copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? gender,
    Map<String, double>? measurements,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      measurements: measurements ?? this.measurements,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
