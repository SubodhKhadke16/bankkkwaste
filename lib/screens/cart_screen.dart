import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/saved_address.dart';
import '../services/cart_service.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';
import 'my_addresses_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to determine if a product is eco-friendly or waste bank
  bool _isEcoFriendlyProduct(String category) {
    const ecoCategories = [
      'Organic',
      'Compost',
      'Edible',
      'Compostable',
      'Reusable',
      'Recycled',
      'Natural'
    ];
    return ecoCategories.contains(category);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          backgroundColor: WastecColors.primaryGreen,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.recycling),
                text: 'Waste Bank',
              ),
              Tab(
                icon: Icon(Icons.eco),
                text: 'Eco-Friendly',
              ),
            ],
          ),
        ),
        body: Consumer<CartService>(
          builder: (context, cartService, child) {
            if (cartService.isEmpty) {
              return _buildEmptyCart(context);
            }

            // Separate items into eco-friendly and waste bank
            final ecoItems = cartService.items
                .where((item) => _isEcoFriendlyProduct(item.product.category))
                .toList();
            final wasteBankItems = cartService.items
                .where((item) => !_isEcoFriendlyProduct(item.product.category))
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Waste Bank Tab
                _buildTabContent(
                  context,
                  cartService,
                  wasteBankItems,
                  'Waste Bank',
                  Icons.recycling,
                  const Color(0xFF00A86B),
                ),
                // Eco-Friendly Tab
                _buildTabContent(
                  context,
                  cartService,
                  ecoItems,
                  'Eco-Friendly',
                  Icons.eco,
                  Colors.green,
                ),
              ],
            );
          },
        ),
      );

  Widget _buildTabContent(
    BuildContext context,
    CartService cartService,
    List<CartItem> items,
    String categoryName,
    IconData icon,
    Color color,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No $categoryName items in cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(categoryName, icon, color),
              ...items.map((cartItem) => _CartItemCard(
                    cartItem: cartItem,
                    isWasteBank: categoryName == 'Waste Bank',
                    onRemove: () =>
                        cartService.removeFromCart(cartItem.product.id),
                    onIncrement: () =>
                        cartService.incrementQuantity(cartItem.product.id),
                    onDecrement: () =>
                        cartService.decrementQuantity(cartItem.product.id),
                  )),
            ],
          ),
        ),
        _buildCheckoutSection(context, cartService, items, categoryName, total),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Browse Products'),
            ),
          ],
        ),
      );

  Widget _buildCheckoutSection(
    BuildContext context,
    CartService cartService,
    List<CartItem> items,
    String categoryName,
    double total,
  ) => Container(
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
                  'Total Items (${items.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: WastecColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _proceedToCheckout(context, items, categoryName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WastecColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  categoryName == 'Waste Bank'
                      ? 'Schedule Pick Up (${items.length} items)'
                      : 'Checkout $categoryName (${items.length} items)',
                  style: const TextStyle(
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

  void _proceedToCheckout(
      BuildContext context, List<CartItem> items, String categoryName) {
    final isEcoFriendly = categoryName == 'Eco-Friendly';
    final cartService = Provider.of<CartService>(context, listen: false);

    if (isEcoFriendly) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _CheckoutDialogScreen(
            cartService: cartService,
            itemsToCheckout: items,
            isEcoFriendly: true,
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _WasteBankScheduleScreen(
            cartService: cartService,
            wasteBankItems: items,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }
}

class _CheckoutDialogScreen extends StatefulWidget {
  const _CheckoutDialogScreen({
    required this.cartService,
    required this.itemsToCheckout,
    required this.isEcoFriendly,
  });

  final CartService cartService;
  final List<CartItem> itemsToCheckout;
  final bool isEcoFriendly;

  @override
  State<_CheckoutDialogScreen> createState() => _CheckoutDialogScreenState();
}

class _CheckoutDialogScreenState extends State<_CheckoutDialogScreen> {
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final locationService = LocationService();
  bool isLoadingLocation = false;
  SavedAddress? selectedAddress;
  String selectedPaymentMethod = 'wallet';
  double walletBalance = 0.0;
  bool isLoadingWallet = false;

  @override
  void initState() {
    super.initState();
    // Auto-fetch location when screen opens
    _autoFetchLocation();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    setState(() => isLoadingWallet = true);
    try {
      final userId = widget.cartService.userId;
      if (userId != null) {
        final userData = await UserService.getUser(userId);
        if (userData != null && mounted) {
          setState(() {
            walletBalance = (userData['walletBalance'] ?? 0.0).toDouble();
          });
        }
      }
    } catch (e) {
      print('Error loading wallet balance: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingWallet = false);
      }
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _autoFetchLocation() async {
    // First, try to load default saved address
    final defaultAddress = await locationService.getSelectedAddress();
    if (defaultAddress != null && mounted) {
      setState(() {
        selectedAddress = defaultAddress;
        addressController.text = defaultAddress.fullAddress;
      });
      return;
    }

    // If no saved address, fall back to current location
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
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
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

  Future<void> _selectAddress() async {
    final result = await Navigator.push<SavedAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAddressesScreen(selectMode: true),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        selectedAddress = result;
        addressController.text = result.fullAddress;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final totalAmount = widget.itemsToCheckout
        .fold<double>(0, (sum, item) => sum + item.totalPrice);

    // Validate wallet balance if wallet payment is selected
    if (selectedPaymentMethod == 'wallet') {
      if (walletBalance < totalAmount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient wallet balance. Available: ₹${walletBalance.toStringAsFixed(2)}, Required: ₹${totalAmount.toStringAsFixed(2)}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // Get current user details from Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'Customer';
    final userEmail = currentUser?.email ?? '';

    // Create order in Firestore with user details and delivery info
    final order = Order(
      id: '',
      userId: widget.cartService.userId ?? 'guest',
      items: widget.itemsToCheckout, // Use only eco items
      totalAmount: totalAmount,
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
      // Process payment based on selected method
      if (selectedPaymentMethod == 'wallet') {
        // Debit from wallet
        final userId = widget.cartService.userId;
        if (userId != null) {
          await TransactionService.debitWalletForPurchase(
            userId: userId,
            amount: totalAmount,
            orderId: orderId,
            userEmail: userEmail,
            description: 'Eco-Friendly Product Purchase - ${widget.itemsToCheckout.length} items',
          );
        }
      }
      // For UPI/Card/COD, payment is processed externally or on delivery

      // Remove only eco items from cart
      for (final item in widget.itemsToCheckout) {
        widget.cartService.removeFromCart(item.product.id);
      }

      // Pop checkout screen
      Navigator.pop(context);

      // Show success
      if (mounted) {
        _showOrderConfirmation(orderId, selectedPaymentMethod);
      }
    }
  }

  void _showOrderConfirmation(String orderId, String paymentMethod) {
    final paymentMethodText = {
      'wallet': 'Wallet',
      'upi': 'UPI',
      'card': 'Card',
      'cod': 'Cash on Delivery',
    }[paymentMethod] ?? paymentMethod;

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
            const SizedBox(height: 8),
            Text(
              'Payment: $paymentMethodText',
              style: const TextStyle(color: Colors.grey),
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
  Widget build(BuildContext context) {
    final itemCount = widget.itemsToCheckout.length;
    final totalAmount = widget.itemsToCheckout
        .fold<double>(0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Eco Products'),
        backgroundColor: Colors.green,
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
                    const Row(
                      children: [
                        Icon(Icons.eco, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Eco Products Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount item${itemCount > 1 ? "s" : ""}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
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
            // Select Address Button
            OutlinedButton.icon(
              onPressed: _selectAddress,
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Select from Saved Addresses'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF00A86B)),
                foregroundColor: const Color(0xFF00A86B),
              ),
            ),
            const SizedBox(height: 16),
            // Address Field
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address *',
                hintText: selectedAddress != null
                    ? '${selectedAddress!.label} - ${selectedAddress!.shortAddress}'
                    : 'Enter your complete address',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  selectedAddress != null ? Icons.bookmark : Icons.location_on,
                  color:
                      selectedAddress != null ? const Color(0xFF00A86B) : null,
                ),
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
            // Payment Method Section
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Wallet Option
                  RadioListTile<String>(
                    value: 'wallet',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value!);
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Color(0xFF00A86B)),
                        SizedBox(width: 12),
                        Text('Wallet'),
                      ],
                    ),
                    subtitle: isLoadingWallet
                        ? const Padding(
                            padding: EdgeInsets.only(left: 36),
                            child: Text('Loading balance...'),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Text(
                              'Available: ₹${walletBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: walletBalance >= totalAmount
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                    activeColor: const Color(0xFF00A86B),
                  ),
                  const Divider(height: 1),
                  // UPI Option
                  RadioListTile<String>(
                    value: 'upi',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value!);
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: Color(0xFF00A86B)),
                        SizedBox(width: 12),
                        Text('UPI'),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Text('Google Pay, PhonePe, Paytm'),
                    ),
                    activeColor: const Color(0xFF00A86B),
                  ),
                  const Divider(height: 1),
                  // Card Option
                  RadioListTile<String>(
                    value: 'card',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value!);
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Color(0xFF00A86B)),
                        SizedBox(width: 12),
                        Text('Credit/Debit Card'),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Text('Visa, Mastercard, RuPay'),
                    ),
                    activeColor: const Color(0xFF00A86B),
                  ),
                  const Divider(height: 1),
                  // COD Option
                  RadioListTile<String>(
                    value: 'cod',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => selectedPaymentMethod = value!);
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.money, color: Color(0xFF00A86B)),
                        SizedBox(width: 12),
                        Text('Cash on Delivery'),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Text('Pay when you receive'),
                    ),
                    activeColor: const Color(0xFF00A86B),
                  ),
                ],
              ),
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
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    this.isWasteBank = false,
  });

  final dynamic cartItem;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isWasteBank;

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
                  if (isWasteBank)
                    // For Waste Bank: Show only quantity without controls
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Qty: ${cartItem.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
                    )
                  else
                    // For Eco-Friendly: Show increment/decrement controls
                    Column(
                      children: [
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
            ],
          ),
        ),
      );
}

// Waste Bank Schedule Screen
class _WasteBankScheduleScreen extends StatefulWidget {
  const _WasteBankScheduleScreen({
    required this.cartService,
    required this.wasteBankItems,
  });

  final CartService cartService;
  final List<CartItem> wasteBankItems;

  @override
  State<_WasteBankScheduleScreen> createState() =>
      _WasteBankScheduleScreenState();
}

class _WasteBankScheduleScreenState extends State<_WasteBankScheduleScreen> {
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final locationService = LocationService();
  DateTime? selectedDate;
  String? selectedTimeSlot;
  bool isLoadingLocation = false;
  SavedAddress? selectedAddress;

  // Time slots from 10 AM to 6 PM
  final List<String> timeSlots = [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _autoFetchLocation();
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _autoFetchLocation() async {
    final defaultAddress = await locationService.getSelectedAddress();
    if (defaultAddress != null && mounted) {
      setState(() {
        selectedAddress = defaultAddress;
        addressController.text = defaultAddress.fullAddress;
      });
      return;
    }

    setState(() => isLoadingLocation = true);
    final position = await locationService.getCurrentPosition();
    if (position == null) {
      if (mounted) setState(() => isLoadingLocation = false);
      return;
    }

    final placemark = await locationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemark != null && mounted) {
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
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
        addressParts.add(placemark.postalCode!);
      }

      addressController.text = addressParts.join(', ');
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<SavedAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAddressesScreen(selectMode: true),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        selectedAddress = result;
        addressController.text = result.fullAddress;
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A86B),
            ),
          ),
          child: child!,
        ),
    );

    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTimeSlot() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Pickup Time Slot'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final slot = timeSlots[index];
              final isSelected = selectedTimeSlot == slot;
              return ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: isSelected ? const Color(0xFF00A86B) : Colors.grey,
                ),
                title: Text(
                  slot,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF00A86B) : null,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: const Color(0xFF00A86B).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => Navigator.pop(context, slot),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (picked != null && mounted) {
      setState(() => selectedTimeSlot = picked);
    }
  }

  Future<void> _schedulePickup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup date')),
      );
      return;
    }

    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup time slot')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'Customer';
    final userEmail = currentUser?.email ?? '';

    // Create waste bank order with pickup details
    final order = Order(
      id: '',
      userId: widget.cartService.userId ?? 'guest',
      items: widget.wasteBankItems,
      totalAmount: 0, // Waste bank - user gets paid, not charged
      status: 'scheduled',
      createdAt: DateTime.now(),
      userName: userName,
      userEmail: userEmail,
      deliveryAddress: addressController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      pickupDate: selectedDate,
      pickupTimeSlot: selectedTimeSlot,
      isWasteBankOrder: true,
    );

    final orderId = await OrderService.createWasteBankOrder(order);

    if (orderId != null && mounted) {
      // Remove waste bank items from cart
      for (final item in widget.wasteBankItems) {
        widget.cartService.removeFromCart(item.product.id);
      }

      Navigator.pop(context);

      if (mounted) {
        _showScheduleConfirmation(orderId);
      }
    }
  }

  void _showScheduleConfirmation(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 28),
            SizedBox(width: 8),
            Text('Pickup Scheduled!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your waste pickup has been scheduled successfully!'),
            const SizedBox(height: 12),
            Text(
              'Schedule ID: ${orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (selectedDate != null && selectedTimeSlot != null) ...[
              const SizedBox(height: 8),
              Text(
                'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Time Slot: $selectedTimeSlot',
                style: const TextStyle(fontSize: 14),
              ),
            ],
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
  Widget build(BuildContext context) {
    final itemCount = widget.wasteBankItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Waste Pickup'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Items Summary Card
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
                    const Row(
                      children: [
                        Icon(Icons.recycling,
                            color: Color(0xFF00A86B), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Waste Bank Materials',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$itemCount item${itemCount > 1 ? "s" : ""} for pickup',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...widget.wasteBankItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} (x${item.quantity})',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                item.product.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pickup Date & Time
            const Text(
              'Pickup Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF00A86B)),
                      foregroundColor: const Color(0xFF00A86B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectTimeSlot,
              icon: const Icon(Icons.access_time),
              label: Text(
                selectedTimeSlot ?? 'Select Time Slot',
                style: const TextStyle(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                side: const BorderSide(color: Color(0xFF00A86B)),
                foregroundColor: const Color(0xFF00A86B),
              ),
            ),
            const SizedBox(height: 24),

            // Pickup Address
            const Text(
              'Pickup Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectAddress,
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Select from Saved Addresses'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF00A86B)),
                foregroundColor: const Color(0xFF00A86B),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Pickup Address *',
                hintText: 'Enter your pickup address',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter pickup address';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a complete address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF00A86B)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Our team will visit your location at the scheduled time to collect the waste materials.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schedule Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _schedulePickup,
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
                  'Schedule Pickup',
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
}
