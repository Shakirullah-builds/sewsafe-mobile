class Client {
  final String? id;
  final String userId;
  final String fullName;
  final String? phoneNumber;
  final String gender;
  final Map<String, double> measurements;
  final String? photoUrl;
  final String? notes;
  final List<Map<String, String>>? stylePhotos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    required this.userId,
    required this.fullName,
    this.phoneNumber,
    required this.gender,
    required this.measurements,
    this.photoUrl,
    this.notes,
    this.stylePhotos,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to parse client record from Supabase JSON response
  factory Client.fromJson(Map<String, dynamic> json) {
    final rawMeasurements = json['measurements'] as Map<String, dynamic>? ?? {};
    
    // Extract photo URL, notes and style photos history from measurements metadata
    final photoUrl = rawMeasurements['_photo_url'] as String?;
    final notes = rawMeasurements['_notes'] as String?;
    final updatedAtStr = rawMeasurements['_updated_at'] as String?;
    final updatedAt = updatedAtStr != null ? DateTime.parse(updatedAtStr) : null;
    
    final rawStylePhotos = rawMeasurements['_style_photos'] as List<dynamic>?;
    final List<Map<String, String>> stylePhotosList = [];
    if (rawStylePhotos != null) {
      for (final item in rawStylePhotos) {
        if (item is Map) {
          stylePhotosList.add({
            'url': item['url']?.toString() ?? '',
            'uploadedAt': item['uploadedAt']?.toString() ?? '',
          });
        }
      }
    }
    
    // Filter out metadata keys to keep measurements strictly numeric
    final measurementsMap = <String, double>{};
    rawMeasurements.forEach((key, value) {
      if (key != '_photo_url' && key != '_notes' && key != '_style_photos' && key != '_updated_at' && value is num) {
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
      stylePhotos: stylePhotosList.isEmpty ? null : stylePhotosList,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: updatedAt,
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
        if (stylePhotos != null) '_style_photos': stylePhotos,
        if (updatedAt != null) '_updated_at': updatedAt!.toIso8601String(),
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
    List<Map<String, String>>? stylePhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      stylePhotos: stylePhotos ?? this.stylePhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
