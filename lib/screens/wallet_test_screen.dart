import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';

/// Demo screen to test wallet functionality
class WalletTestScreen extends StatefulWidget {
  const WalletTestScreen({super.key});

  @override
  State<WalletTestScreen> createState() => _WalletTestScreenState();
}

class _WalletTestScreenState extends State<WalletTestScreen> {
  final AuthService _authService = AuthService();
  bool _isCreatingOrder = false;
  String? _lastOrderId;
  String? _userId;
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      setState(() => _userId = userId);
      _refreshBalance();
    }
  }

  Future<void> _refreshBalance() async {
    if (_userId == null) return;
    final userData = await UserService.getUser(_userId!);
    if (userData != null) {
      setState(() {
        _currentBalance = (userData['walletBalance'] ?? 0.0).toDouble();
      });
    }
  }

  Future<void> _createTestWasteBankOrder() async {
    if (_userId == null) {
      _showMessage('Please login first');
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      // Create a test waste bank order
      final order = Order(
        id: '',
        userId: _userId!,
        items: [
          CartItem(
            product: Product(
              id: 'test1',
              name: 'Plastic Bottles',
              description: 'Test plastic bottles',
              price: 10,
              imageUrl: '',
              category: 'Plastic',
              stock: 100,
            ),
            quantity: 5,
          ),
          CartItem(
            product: Product(
              id: 'test2',
              name: 'Paper Waste',
              description: 'Test paper waste',
              price: 15,
              imageUrl: '',
              category: 'Paper',
              stock: 100,
            ),
            quantity: 3,
          ),
        ],
        totalAmount: 95, // 5*10 + 3*15
        status: 'pending',
        createdAt: DateTime.now(),
        isWasteBankOrder: true,
        userName: 'Test User',
        phoneNumber: '1234567890',
      );

      final orderId = await OrderService.createWasteBankOrder(order);

      if (orderId != null) {
        setState(() => _lastOrderId = orderId);
        _showMessage('Test order created! Order ID: $orderId');
      } else {
        _showMessage('Failed to create order');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isCreatingOrder = false);
    }
  }

  Future<void> _completeOrder() async {
    if (_lastOrderId == null) {
      _showMessage('Create an order first');
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      // Complete the order (this will automatically credit the wallet)
      final success = await OrderService.updateOrderStatus(
        _lastOrderId!,
        'completed',
        isWasteBankOrder: true,
      );

      if (success) {
        _showMessage('Order completed! Wallet credited with ₹95.00');
        await _refreshBalance();
      } else {
        _showMessage('Failed to complete order');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isCreatingOrder = false);
    }
  }

  Future<void> _addTestCredit() async {
    if (_userId == null) {
      _showMessage('Please login first');
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      // Get user email
      String? userEmail;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        userEmail = user.email;
      }
      
      await TransactionService.addMoney(
        userId: _userId!,
        amount: 100,
        userEmail: userEmail,
        paymentMethod: 'Test Payment',
      );

      _showMessage('₹100 added to wallet');
      await _refreshBalance();
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isCreatingOrder = false);
    }
  }

  Future<void> _addTestDebit() async {
    if (_userId == null) {
      _showMessage('Please login first');
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      // Get user email
      String? userEmail;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        userEmail = user.email;
      }
      
      await TransactionService.createTransaction(
        userId: _userId!,
        amount: 50,
        type: 'debit',
        userEmail: userEmail,
        description: 'Test Purchase',
        category: 'eco_friendly',
      );

      _showMessage('₹50 debited from wallet');
      await _refreshBalance();
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isCreatingOrder = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: WastecColors.primaryGreen,
          title: const Text(
            'Wallet Test Screen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WastecColors.primaryGreen,
                        WastecColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Wallet Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${_currentBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _refreshBalance,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Create a test waste bank order\n'
                        '2. Complete the order to credit wallet automatically\n'
                        '3. Check transaction history in wallet screen',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Test Actions
                const Text(
                  'Test Order Flow',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _TestButton(
                  label: '1. Create Test Order (₹95.00)',
                  icon: Icons.add_shopping_cart,
                  onPressed: _isCreatingOrder ? null : _createTestWasteBankOrder,
                  isLoading: _isCreatingOrder,
                ),

                const SizedBox(height: 12),

                _TestButton(
                  label: '2. Complete Order → Credit Wallet',
                  icon: Icons.check_circle,
                  onPressed: _isCreatingOrder || _lastOrderId == null
                      ? null
                      : _completeOrder,
                  isLoading: _isCreatingOrder,
                  color: Colors.green,
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 16),

                const Text(
                  'Direct Wallet Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _TestButton(
                  label: 'Add ₹100 (Test Credit)',
                  icon: Icons.add_circle,
                  onPressed: _isCreatingOrder ? null : _addTestCredit,
                  isLoading: _isCreatingOrder,
                  color: Colors.blue,
                ),

                const SizedBox(height: 12),

                _TestButton(
                  label: 'Deduct ₹50 (Test Debit)',
                  icon: Icons.remove_circle,
                  onPressed: _isCreatingOrder ? null : _addTestDebit,
                  isLoading: _isCreatingOrder,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      );
}

class _TestButton extends StatelessWidget {
  const _TestButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? WastecColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
