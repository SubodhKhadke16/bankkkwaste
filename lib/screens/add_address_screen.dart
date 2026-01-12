import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/theme.dart';
import '../models/saved_address.dart';
import '../services/location_service.dart';

/// Screen to add or edit a delivery address
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    this.address,
    this.currentPosition,
  });

  final SavedAddress? address;
  final Position? currentPosition;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final LocationService _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _selectedLabel = 'Home';
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;

  final List<String> _addressLabels = ['Home', 'Work', 'Hotel', 'Other'];

  @override
  void initState() {
    super.initState();
    
    final addr = widget.address;
    _addressLine1Controller = TextEditingController(text: addr?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: addr?.addressLine2 ?? '');
    _landmarkController = TextEditingController(text: addr?.landmark ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController = TextEditingController(text: addr?.state ?? '');
    _pincodeController = TextEditingController(text: addr?.pincode ?? '');
    
    if (addr != null) {
      _selectedLabel = addr.label;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
    } else if (widget.currentPosition != null) {
      _latitude = widget.currentPosition!.latitude;
      _longitude = widget.currentPosition!.longitude;
      _loadAddressFromPosition();
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressFromPosition() async {
    if (_latitude == null || _longitude == null) return;

    final placemark = await _locationService.getAddressFromCoordinates(
      _latitude!,
      _longitude!,
    );

    if (placemark != null && mounted) {
      setState(() {
        _addressLine1Controller.text = placemark.street ?? '';
        _addressLine2Controller.text = placemark.subLocality ?? '';
        _landmarkController.text = placemark.subThoroughfare ?? '';
        _cityController.text = placemark.locality ?? '';
        _stateController.text = placemark.administrativeArea ?? '';
        _pincodeController.text = placemark.postalCode ?? '';
      });
    }
  }

  Future<void> _pickLocationOnMap() async {
    // Navigate to map picker screen
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => _MapPickerScreen(
          initialPosition: _latitude != null && _longitude != null
              ? LatLng(_latitude!, _longitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      _loadAddressFromPosition();
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final address = SavedAddress(
      id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: _selectedLabel,
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim(),
      landmark: _landmarkController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    final success = await _locationService.saveAddress(address);

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save address')),
        );
      }
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
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Location picker (optional - map requires API key)
            InkWell(
              onTap: _pickLocationOnMap,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _latitude != null && _longitude != null
                          ? Icons.location_on
                          : Icons.map_outlined,
                      size: 48,
                      color: _latitude != null && _longitude != null
                          ? WastecColors.primaryGreen
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _latitude != null && _longitude != null
                          ? 'Location selected\nTap to change'
                          : 'Tap to select location on map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _latitude != null && _longitude != null
                            ? WastecColors.primaryGreen
                            : Colors.grey.shade600,
                        fontWeight: _latitude != null && _longitude != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (_latitude != null && _longitude != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Address Label
            const Text(
              'Save As',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: _addressLabels.map((label) {
                final isSelected = _selectedLabel == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLabel = label);
                    }
                  },
                  selectedColor: WastecColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Address Line 1
            TextFormField(
              controller: _addressLine1Controller,
              decoration: _inputDecoration('House/Flat/Block No. *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Address Line 2
            TextFormField(
              controller: _addressLine2Controller,
              decoration: _inputDecoration('Apartment/Road/Area'),
            ),

            const SizedBox(height: 16),

            // Landmark
            TextFormField(
              controller: _landmarkController,
              decoration: _inputDecoration('Landmark (Optional)'),
            ),

            const SizedBox(height: 16),

            // City and State
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration('City *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: _inputDecoration('State *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pincode
            TextFormField(
              controller: _pincodeController,
              decoration: _inputDecoration('Pincode *'),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Pincode is required';
                }
                if (value.length != 6) {
                  return 'Invalid pincode';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WastecColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );

  InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WastecColors.primaryGreen),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
}

/// Simple map picker screen
class _MapPickerScreen extends StatefulWidget {
  const _MapPickerScreen({this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  late LatLng _selectedPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? const LatLng(19.0760, 72.8777); // Mumbai default
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedPosition),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 64,
              color: WastecColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Location: ${_selectedPosition.latitude.toStringAsFixed(4)}, ${_selectedPosition.longitude.toStringAsFixed(4)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Google Maps requires an API key. Configure it in AndroidManifest.xml to enable map picker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
