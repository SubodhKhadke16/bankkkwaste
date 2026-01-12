import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../services/location_service.dart';
import '../screens/select_location_screen.dart';

/// Reusable location header widget similar to Zepto's delivery time banner
class LocationHeader extends StatefulWidget {
  const LocationHeader({super.key});

  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader> {
  final LocationService _locationService = LocationService();
  String _selectedAddress = 'Select Location';
  final String _deliveryTime = '5 minutes';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress();
  }

  Future<void> _loadSelectedAddress() async {
    setState(() => _isLoading = true);

    // Try to get selected address
    final address = await _locationService.getSelectedAddress();
    
    if (address != null) {
      setState(() {
        _selectedAddress = address.shortAddress;
        _isLoading = false;
      });
      return;
    }

    // Try to get current location data
    final currentData = await _locationService.getCurrentLocationData();
    if (currentData != null) {
      setState(() {
        _selectedAddress = currentData['address'] as String;
        _isLoading = false;
      });
      return;
    }

    // No location set
    setState(() {
      _selectedAddress = 'Select Location';
      _isLoading = false;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result['address'] as String? ?? 'Select Location';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        color: WastecColors.primaryGreen,
      ),
      child: Row(
        children: [
          // Delivery time icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Location info
          Expanded(
            child: InkWell(
              onTap: _openLocationPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _deliveryTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (_isLoading) const SizedBox(
                          width: 100,
                          height: 12,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) else Text(
                          _selectedAddress,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

/// Compact version of location header for smaller spaces
class CompactLocationHeader extends StatefulWidget {
  const CompactLocationHeader({super.key});

  @override
  State<CompactLocationHeader> createState() => _CompactLocationHeaderState();
}

class _CompactLocationHeaderState extends State<CompactLocationHeader> {
  final LocationService _locationService = LocationService();
  String _selectedAddress = 'Select Location';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress();
  }

  Future<void> _loadSelectedAddress() async {
    setState(() => _isLoading = true);

    final address = await _locationService.getSelectedAddress();
    if (address != null) {
      setState(() {
        _selectedAddress = address.shortAddress;
        _isLoading = false;
      });
      return;
    }

    final currentData = await _locationService.getCurrentLocationData();
    if (currentData != null) {
      setState(() {
        _selectedAddress = currentData['address'] as String;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _selectedAddress = 'Select Location';
      _isLoading = false;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result['address'] as String? ?? 'Select Location';
      });
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: _openLocationPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: WastecColors.lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: WastecColors.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: WastecColors.primaryGreen,
            ),
            const SizedBox(width: 6),
            if (_isLoading) const SizedBox(
                    width: 80,
                    height: 12,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(WastecColors.primaryGreen),
                    ),
                  ) else Flexible(
                    child: Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
}
