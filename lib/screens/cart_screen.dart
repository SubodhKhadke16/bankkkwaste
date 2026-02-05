import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../widgets/wastec_bottom_nav.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartService.items[index];
                    return _CartItemCard(
                      cartItem: cartItem,
                      onRemove: () =>
                          cartService.removeFromCart(cartItem.product.id),
                      onIncrement: () =>
                          cartService.incrementQuantity(cartItem.product.id),
                      onDecrement: () =>
                          cartService.decrementQuantity(cartItem.product.id),
                    );
                  },
                ),
              ),
              _buildCartSummary(context, cartService),
            ],
          );
        },
      ),
      bottomNavigationBar: WastecBottomNav(
        currentIndex: 0,
        onTap: (index) {
          WastecBottomNav.navigateTo(context, index);
        },
      ),
    );

  Widget _buildEmptyCart(BuildContext context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add eco-friendly products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );

  Widget _buildCartSummary(BuildContext context, CartService cartService) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items (${cartService.itemCount})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹${cartService.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${cartService.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A86B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCheckoutDialog(context, cartService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  void _showCheckoutDialog(BuildContext context, CartService cartService) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CheckoutDialogScreen(cartService: cartService),
        fullscreenDialog: true,
      ),
    );
  }
}

class _CheckoutDialogScreen extends StatefulWidget {
  const _CheckoutDialogScreen({required this.cartService});

  final CartService cartService;

  @override
  State<_CheckoutDialogScreen> createState() => _CheckoutDialogScreenState();
}

class _CheckoutDialogScreenState extends State<_CheckoutDialogScreen> {
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final locationService = LocationService();
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Auto-fetch location when screen opens
    _autoFetchLocation();
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _autoFetchLocation() async {
    final hasPermission = await locationService.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission needed for delivery'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final position = await locationService.getCurrentPosition();
    if (position == null) return;

    final placemark = await locationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemark != null && mounted) {
      // Format complete address
      final addressParts = <String>[];
      if (placemark.street != null && placemark.street!.isNotEmpty) {
        addressParts.add(placemark.street!);
      }
      if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
        addressParts.add(placemark.subLocality!);
      }
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
        addressParts.add(placemark.postalCode!);
      }

      final fullAddress = addressParts.join(', ');
      addressController.text = fullAddress;
    }
  }

  Future<void> _refreshLocation() async {
    setState(() => isLoadingLocation = true);
    await _autoFetchLocation();
    if (mounted) {
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Get current user details from Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'Customer';
    final userEmail = currentUser?.email ?? '';

    // Create order in Firestore with user details and delivery info
    final order = Order(
      id: '',
      userId: widget.cartService.userId ?? 'guest',
      items: widget.cartService.items,
      totalAmount: widget.cartService.totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
      userName: userName,
      userEmail: userEmail,
      deliveryAddress: addressController.text.trim(),
      phoneNumber: phoneController.text.trim(),
    );

    // Save order and get ID
    final orderId = await OrderService.createOrder(order);

    if (orderId != null && mounted) {
      // Clear cart
      widget.cartService.clearCart();

      // Pop checkout screen
      Navigator.pop(context);

      // Show success
      if (mounted) {
        _showOrderConfirmation(orderId);
      }
    }
  }

  void _showOrderConfirmation(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 28),
            SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully!'),
            const SizedBox(height: 12),
            Text(
              'Order ID: ${orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Order Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.cartService.itemCount} items',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '₹${widget.cartService.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A86B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Delivery Details Header
            const Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Address Field
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address *',
                hintText: 'Enter your complete address',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: Color(0xFF00A86B)),
                  onPressed: isLoadingLocation ? null : _refreshLocation,
                  tooltip: 'Use current location',
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter delivery address';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a complete address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Phone Field
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final dynamic cartItem;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cartItem.product.imageUrl.isNotEmpty
                  ? Image.asset(
                      cartItem.product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.eco,
                            size: 40, color: Color(0xFF00A86B)),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.eco,
                          size: 40, color: Color(0xFF00A86B)),
                    ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.product.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${cartItem.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A86B),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove, size: 16),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add, size: 16),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
}
