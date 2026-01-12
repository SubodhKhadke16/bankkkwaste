import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wallet_tab.dart';
import '../widgets/wastec_order_card.dart';
import 'home_clean.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  bool _showInProgress = true;

  @override
  Widget build(BuildContext context) {
    final orders = WastecBankData.orders;
    final inProgressOrders = orders.where((order) => (order['stage']! as int) < 5).toList();
    final completedOrders = orders.where((order) => (order['stage']! as int) >= 5).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WastecColors.primaryGreen,
        title: const Text(
          'Track Your Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: const [ProfileWalletActions()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1: Book Your New Pickup Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WastecColors.primaryGreen,
                    WastecColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: WastecColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Book Your New Pickup',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to earn from your scrap? Schedule a pickup now.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Start New Pickup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: WastecColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section 2: Orders Tabs (In Progress / History)
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: 'Orders in Progress',
                    icon: Icons.local_shipping_outlined,
                    isActive: _showInProgress,
                    onTap: () => setState(() => _showInProgress = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    label: 'Order History',
                    icon: Icons.history,
                    isActive: !_showInProgress,
                    onTap: () => setState(() => _showInProgress = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Orders List
            if (_showInProgress)
              inProgressOrders.isEmpty
                  ? _buildEmptyState('No Active Orders', 'Your in-progress pickups will appear here')
                  : Column(
                      children: inProgressOrders.map((order) => _buildSimplifiedOrderCard(context, order)).toList(),
                    )
            else
              completedOrders.isEmpty
                  ? _buildEmptyState('No Order History', 'Your completed orders will appear here')
                  : Column(
                      children: completedOrders.map((order) => _buildSimplifiedOrderCard(context, order)).toList(),
                    ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    // Waste Bank navbar: Home, Waste Bank, Track Order, Wallet
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              // Home/Back button
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: WastecColors.mediumGray,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 11,
                          color: WastecColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Vertical divider
              Container(
                width: 1,
                height: 35,
                color: Colors.grey.shade300,
              ),
              // Waste Bank
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.recycling,
                        color: WastecColors.mediumGray,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Waste Bank',
                        style: TextStyle(
                          fontSize: 11,
                          color: WastecColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Track Order (selected)
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: WastecColors.primaryGreen,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track Order',
                        style: TextStyle(
                          fontSize: 11,
                          color: WastecColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Wallet
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(initialIndex: 3),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: WastecColors.mediumGray,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 11,
                          color: WastecColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplifiedOrderCard(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] as String;
    final orderId = order['id'] as String;
    final eta = order['eta'] as String;
    final weight = order['weight'] as String;
    final date = order['date'] as String;
    final stage = order['stage'] as int;

    // Determine icon based on order stage
    final isCompleted = stage >= 5;
    final iconData = isCompleted ? Icons.verified : Icons.local_shipping_outlined;
    final iconBackground = isCompleted ? const Color(0xFFD1F0EC) : const Color(0xFFFFE8D6);
    final iconColor = isCompleted ? const Color(0xFF0B8C54) : const Color(0xFFFF8C32);

    return GestureDetector(
      onTap: () => _showOrderDetails(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WastecColors.primaryGreen.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Order ID and Status Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: WastecColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WastecColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            // Weight and ETA
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weight,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ETA',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eta,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WastecColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // View Details Hint
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: 11,
                    color: WastecColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: WastecColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: WastecOrderCard(order: order),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) => Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: WastecColors.primaryGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? WastecColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: WastecColors.primaryGreen.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: WastecColors.primaryGreen.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : WastecColors.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : WastecColors.primaryGreen,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
}
