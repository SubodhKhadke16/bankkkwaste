import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_address.dart';

/// Service to manage user locations and saved addresses
class LocationService {
  static const String _savedAddressesKey = 'saved_addresses';
  static const String _selectedAddressIdKey = 'selected_address_id';
  static const String _currentLocationKey = 'current_location';

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Get current device location
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates using reverse geocoding
  Future<Placemark?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address using geocoding
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      return locations.isNotEmpty ? locations.first : null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Get all saved addresses
  Future<List<SavedAddress>> getSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_savedAddressesKey);
      if (addressesJson == null) return [];

      final List<dynamic> decoded = jsonDecode(addressesJson);
      return decoded
          .map((json) => SavedAddress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting saved addresses: $e');
      return [];
    }
  }

  /// Save a new address
  Future<bool> saveAddress(SavedAddress address) async {
    try {
      final addresses = await getSavedAddresses();
      
      // Check if address with same ID exists, update it
      final existingIndex = addresses.indexWhere((a) => a.id == address.id);
      if (existingIndex != -1) {
        addresses[existingIndex] = address.copyWith(updatedAt: DateTime.now());
      } else {
        addresses.add(address);
      }

      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
      return await prefs.setString(_savedAddressesKey, encoded);
    } catch (e) {
      print('Error saving address: $e');
      return false;
    }
  }

  /// Delete a saved address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final addresses = await getSavedAddresses();
      addresses.removeWhere((a) => a.id == addressId);

      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
      return await prefs.setString(_savedAddressesKey, encoded);
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  /// Get the currently selected address
  Future<SavedAddress?> getSelectedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedId = prefs.getString(_selectedAddressIdKey);
      if (selectedId == null) return null;

      final addresses = await getSavedAddresses();
      return addresses.firstWhere(
        (a) => a.id == selectedId,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw StateError('No address found'),
      );
    } catch (e) {
      print('Error getting selected address: $e');
      return null;
    }
  }

  /// Set the selected address
  Future<bool> setSelectedAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_selectedAddressIdKey, addressId);
    } catch (e) {
      print('Error setting selected address: $e');
      return false;
    }
  }

  /// Save current location as temporary
  Future<bool> saveCurrentLocation(Position position, String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return await prefs.setString(_currentLocationKey, jsonEncode(locationData));
    } catch (e) {
      print('Error saving current location: $e');
      return false;
    }
  }

  /// Get saved current location
  Future<Map<String, dynamic>?> getCurrentLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_currentLocationKey);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting current location data: $e');
      return null;
    }
  }

  /// Update distances for all saved addresses based on current position
  Future<List<SavedAddress>> updateAddressDistances(Position currentPosition) async {
    final addresses = await getSavedAddresses();
    final updatedAddresses = <SavedAddress>[];

    for (final address in addresses) {
      if (address.latitude != null && address.longitude != null) {
        final distance = calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          address.latitude!,
          address.longitude!,
        );
        updatedAddresses.add(address.copyWith(distanceKm: distance));
      } else {
        updatedAddresses.add(address);
      }
    }

    // Sort by distance
    updatedAddresses.sort((a, b) {
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      return a.distanceKm!.compareTo(b.distanceKm!);
    });

    return updatedAddresses;
  }

  /// Search addresses (mock implementation - can be replaced with actual API)
  Future<List<Map<String, String>>> searchAddresses(String query) async {
    // This is a mock implementation. In production, you'd call a geocoding API
    // like Google Places API, Mapbox, or OpenStreetMap Nominatim
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (query.isEmpty) return [];

    // Mock results
    return [
      {
        'title': '$query, Mumbai, Maharashtra',
        'subtitle': 'Maharashtra 400001',
      },
      {
        'title': '$query, Pune, Maharashtra',
        'subtitle': 'Maharashtra 411001',
      },
      {
        'title': '$query, Delhi',
        'subtitle': 'Delhi 110001',
      },
    ];
  }
}
