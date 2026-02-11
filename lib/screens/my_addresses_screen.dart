import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../config/theme.dart';
import '../models/saved_address.dart';
import '../services/location_service.dart';
import 'add_edit_address_screen.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({Key? key, this.selectMode = false}) : super(key: key);

  /// If true, screen acts as address selector for checkout
  final bool selectMode;

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final LocationService _locationService = LocationService();
  List<SavedAddress> _addresses = [];
  SavedAddress? _selectedAddress;
  bool _isLoading = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);

    try {
      // Get current position for distance calculation
      _currentPosition = await _locationService.getCurrentPosition();

      // Load addresses
      List<SavedAddress> addresses;
      if (_currentPosition != null) {
        addresses = await _locationService.updateAddressDistances(_currentPosition!);
      } else {
        addresses = await _locationService.getSavedAddresses();
      }

      // Get selected address
      final selected = await _locationService.getSelectedAddress();

      if (mounted) {
        setState(() {
          _addresses = addresses;
          _selectedAddress = selected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading addresses: $e')),
        );
      }
    }
  }

  Future<void> _addCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to get current location')),
          );
        }
        return;
      }

      final placemark = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      // Navigate to add address screen with current location data
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditAddressScreen(
            initialLatitude: position.latitude,
            initialLongitude: position.longitude,
            initialPlacemark: placemark,
          ),
        ),
      );

      if (result == true) {
        _loadAddresses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _selectAddress(SavedAddress address) async {
    if (widget.selectMode) {
      // Return selected address to previous screen
      Navigator.pop(context, address);
    } else {
      // Set as default address
      await _locationService.setSelectedAddress(address.id);
      setState(() => _selectedAddress = address);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${address.label} set as default address')),
        );
      }
    }
  }

  Future<void> _deleteAddress(SavedAddress address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _locationService.deleteAddress(address.id);
      _loadAddresses();
    }
  }

  Future<void> _editAddress(SavedAddress address) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    if (result == true) {
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Address' : 'My Addresses'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditAddressScreen(),
            ),
          );
          if (result == true) {
            _loadAddresses();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
        backgroundColor: WastecColors.primaryGreen,
      ),
    );

  Widget _buildEmptyState() => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Addresses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first address to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
            ),
          ],
        ),
      ),
    );

  Widget _buildAddressList() => Column(
      children: [
        if (!widget.selectMode)
          Container(
            padding: const EdgeInsets.all(16),
            color: WastecColors.lightGreen,
            child: Row(
              children: [
                const Icon(Icons.my_location, color: WastecColors.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _addCurrentLocation,
                    child: const Text('Use Current Location'),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAddresses,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                final isSelected = _selectedAddress?.id == address.id;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? WastecColors.primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _selectAddress(address),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: WastecColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconForLabel(address.label),
                                      size: 16,
                                      color: WastecColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      address.label,
                                      style: const TextStyle(
                                        color: WastecColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected && !widget.selectMode) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WastecColors.successGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (address.distanceKm != null)
                                Text(
                                  '${address.distanceKm!.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            address.addressLine1,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (address.addressLine2.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              address.addressLine2,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${address.city}, ${address.state} ${address.pincode}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (address.landmark.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Landmark: ${address.landmark}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _editAddress(address),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: WastecColors.primaryGreen,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteAddress(address),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
      case 'office':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
