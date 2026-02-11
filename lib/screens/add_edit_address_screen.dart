import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';

import '../config/theme.dart';
import '../models/saved_address.dart';
import '../services/location_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({
    Key? key,
    this.address,
    this.initialLatitude,
    this.initialLongitude,
    this.initialPlacemark,
  }) : super(key: key);

  final SavedAddress? address;
  final double? initialLatitude;
  final double? initialLongitude;
  final Placemark? initialPlacemark;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();

  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _selectedLabel = 'Home';
  final List<String> _labels = ['Home', 'Work', 'Other'];
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.address != null) {
      // Editing existing address
      final addr = widget.address!;
      _addressLine1Controller = TextEditingController(text: addr.addressLine1);
      _addressLine2Controller = TextEditingController(text: addr.addressLine2);
      _landmarkController = TextEditingController(text: addr.landmark);
      _cityController = TextEditingController(text: addr.city);
      _stateController = TextEditingController(text: addr.state);
      _pincodeController = TextEditingController(text: addr.pincode);
      _selectedLabel = addr.label;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
    } else if (widget.initialPlacemark != null) {
      // Adding new address from current location
      final p = widget.initialPlacemark!;
      _addressLine1Controller = TextEditingController(
        text: '${p.street ?? ''} ${p.subLocality ?? ''}'.trim(),
      );
      _addressLine2Controller = TextEditingController();
      _landmarkController = TextEditingController(text: p.subLocality ?? '');
      _cityController = TextEditingController(text: p.locality ?? '');
      _stateController = TextEditingController(text: p.administrativeArea ?? '');
      _pincodeController = TextEditingController(text: p.postalCode ?? '');
      _latitude = widget.initialLatitude;
      _longitude = widget.initialLongitude;
    } else {
      // Adding new address manually
      _addressLine1Controller = TextEditingController();
      _addressLine2Controller = TextEditingController();
      _landmarkController = TextEditingController();
      _cityController = TextEditingController();
      _stateController = TextEditingController();
      _pincodeController = TextEditingController();
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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to get current location')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final placemark = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemark != null && mounted) {
        setState(() {
          _addressLine1Controller.text =
              '${placemark.street ?? ''} ${placemark.subLocality ?? ''}'.trim();
          _landmarkController.text = placemark.subLocality ?? '';
          _cityController.text = placemark.locality ?? '';
          _stateController.text = placemark.administrativeArea ?? '';
          _pincodeController.text = placemark.postalCode ?? '';
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final address = SavedAddress(
        id: widget.address?.id ?? const Uuid().v4(),
        label: _selectedLabel,
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        createdAt: widget.address?.createdAt,
      );

      final success = await _locationService.saveAddress(address);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save address')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              tooltip: 'Use Current Location',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Save address as',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _labels.map((label) {
                        final isSelected = _selectedLabel == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedLabel = label);
                              }
                            },
                            selectedColor: WastecColors.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _addressLine1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 1 *',
                        hintText: 'House/Flat No., Building Name',
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter address line 1';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressLine2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 2',
                        hintText: 'Street, Area, Colony',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _landmarkController,
                      decoration: const InputDecoration(
                        labelText: 'Landmark',
                        hintText: 'Near famous place (optional)',
                        prefixIcon: Icon(Icons.pin_drop),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _pincodeController,
                            decoration: const InputDecoration(
                              labelText: 'Pincode *',
                              prefixIcon: Icon(Icons.pin),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Required';
                              }
                              if (value!.length != 6) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WastecColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Address' : 'Save Address',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
