import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../config/theme.dart';
import '../models/saved_address.dart';
import '../services/location_service.dart';
import 'add_address_screen.dart';

/// Screen to select delivery location similar to Zepto
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<SavedAddress> _savedAddresses = [];
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingCurrentLocation = false;
  bool _isLoadingAddresses = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _loadCurrentPosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentPosition() async {
    final position = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
      if (position != null) {
        _updateAddressDistances();
      }
    }
  }

  Future<void> _loadSavedAddresses() async {
    setState(() => _isLoadingAddresses = true);
    final addresses = await _locationService.getSavedAddresses();
    if (mounted) {
      setState(() {
        _savedAddresses = addresses;
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _updateAddressDistances() async {
    if (_currentPosition == null) return;
    final updatedAddresses = await _locationService.updateAddressDistances(_currentPosition!);
    if (mounted) {
      setState(() {
        _savedAddresses = updatedAddresses;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _locationService.searchAddresses(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingCurrentLocation = true);
    
    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      setState(() => _isLoadingCurrentLocation = false);
      return;
    }

    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
      setState(() => _isLoadingCurrentLocation = false);
      return;
    }

    final placemark = await _locationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() => _isLoadingCurrentLocation = false);

    if (placemark != null && mounted) {
      final address = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}';
      
      // Save and select this location
      await _locationService.saveCurrentLocation(position, address);
      await _locationService.setSelectedAddress('current');
      
      if (mounted) {
        Navigator.pop(context, {
          'address': address,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'isCurrent': true,
        });
      }
    }
  }

  Future<void> _selectAddress(SavedAddress address) async {
    await _locationService.setSelectedAddress(address.id);
    if (mounted) {
      Navigator.pop(context, {
        'address': address.shortAddress,
        'fullAddress': address.fullAddress,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isCurrent': false,
      });
    }
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(currentPosition: _currentPosition),
      ),
    );
    
    if (result == true) {
      _loadSavedAddresses();
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
      _loadSavedAddresses();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchAddress,
              decoration: InputDecoration(
                hintText: 'Search Address',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Search results or main content
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildMainContent(),
          ),
        ],
      ),
    );

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
          title: Text(
            result['title']!,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(result['subtitle']!),
          onTap: () {
            // Handle search result selection
            Navigator.pop(context, {'address': result['title']});
          },
        );
      },
    );
  }

  Widget _buildMainContent() => ListView(
      children: [
        // Use Current Location
        _buildActionTile(
          icon: Icons.my_location,
          iconColor: Colors.pink,
          title: 'Use my Current Location',
          isLoading: _isLoadingCurrentLocation,
          onTap: _useCurrentLocation,
        ),

        const Divider(height: 1),

        // Add New Address
        _buildActionTile(
          icon: Icons.add,
          iconColor: Colors.pink,
          title: 'Add New Address',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: _navigateToAddAddress,
        ),

        const Divider(height: 1),

        // Request address from friend (placeholder)
        _buildActionTile(
          icon: Icons.chat_outlined,
          iconColor: Colors.green,
          title: 'Request address from friend',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feature coming soon!')),
            );
          },
        ),

        const SizedBox(height: 24),

        // Saved Addresses
        if (_savedAddresses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Saved Addresses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._savedAddresses.map(_buildSavedAddressTile),
        ],

        if (_isLoadingAddresses)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap, Widget? trailing,
    bool isLoading = false,
  }) =>
      InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (trailing != null)
                trailing,
            ],
          ),
        ),
      );

  Widget _buildSavedAddressTile(SavedAddress address) => InkWell(
      onTap: () => _selectAddress(address),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.distanceKm != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${address.distanceKm!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteAddress(address);
                }
              },
            ),
          ],
        ),
      ),
    );
}
