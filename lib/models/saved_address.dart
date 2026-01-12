import 'dart:convert';

/// Model representing a saved address
class SavedAddress {

  SavedAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2 = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        addressLine1: json['addressLine1'] as String,
        addressLine2: json['addressLine2'] as String? ?? '',
        landmark: json['landmark'] as String? ?? '',
        city: json['city'] as String,
        state: json['state'] as String,
        pincode: json['pincode'] as String,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        distanceKm: json['distanceKm'] as double?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
  final String id;
  final String label; // e.g., "Home", "Work", "Other"
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final double? distanceKm; // Distance from current location
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Get formatted full address
  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      if (landmark.isNotEmpty) landmark,
      city,
      state,
      pincode,
    ];
    return parts.join(', ');
  }

  /// Get short address (first line only)
  String get shortAddress {
    final parts = <String>[
      addressLine1,
      city,
    ];
    return parts.join(', ');
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'distanceKm': distanceKm,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create a copy with updated fields
  SavedAddress copyWith({
    String? id,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      SavedAddress(
        id: id ?? this.id,
        label: label ?? this.label,
        addressLine1: addressLine1 ?? this.addressLine1,
        addressLine2: addressLine2 ?? this.addressLine2,
        landmark: landmark ?? this.landmark,
        city: city ?? this.city,
        state: state ?? this.state,
        pincode: pincode ?? this.pincode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        distanceKm: distanceKm ?? this.distanceKm,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'SavedAddress(label: $label, address: $shortAddress)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAddress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
