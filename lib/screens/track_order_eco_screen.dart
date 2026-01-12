import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';
import 'home_clean.dart';

class TrackOrderEcoScreen extends StatelessWidget {
  const TrackOrderEcoScreen({super.key});

  static final List<Map<String, dynamic>> _sampleOrders = [
    {
      'name': 'Biodegradable Garbage Bags',
      'status': 'Arriving Today',
      'date': '17 December',
      'icon': Icons.shopping_bag,
      'color': Colors.orange,
    },
    {
      'name': 'Cocopeat Block 1kg',
      'status': 'Delivered',
      'date': '15 December',
      'icon': Icons.grass,
      'color': Colors.green,
    },
    {
      'name': 'Bamboo Toothbrush',
      'status': 'Delivered',
      'date': '12 December',
      'icon': Icons.brush,
      'color': const Color(0xFF8B4513),
    },
    {
      'name': 'Coir Compost Mix',
      'status': 'Delivered',
      'date': '10 December',
      'icon': Icons.eco,
      'color': const Color(0xFF6B4423),
    },
    {
      'name': 'Edible Rice Plates (Pack of 10)',
      'status': 'Delivered',
      'date': '8 December',
      'icon': Icons.restaurant,
      'color': Colors.amber,
    },
    {
      'name': 'Cloth Shopping Bag',
      'status': 'Delivered',
      'date': '5 December',
      'icon': Icons.local_mall,
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search your orders...',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Order history header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Order History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Past three months',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Orders list
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _sampleOrders.length,
              itemBuilder: (context, index) {
                final order = _sampleOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
            // End message
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'You have reached the end of your orders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) => GestureDetector(
      onTap: () => _showOrderDetails(context, order),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (order['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    order['icon'] as IconData,
                    size: 40,
                    color: order['color'] as Color,
                  ),
                ),
                const SizedBox(width: 12),
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['name'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order['status'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: order['status'] == 'Arriving Today'
                              ? Colors.teal
                              : Colors.grey[600],
                          fontWeight: order['status'] == 'Arriving Today'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Status Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #123456789',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: order['status'] == 'Arriving Today'
                                      ? Colors.teal.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: order['status'] == 'Arriving Today'
                                        ? Colors.teal.shade200
                                        : Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  order['status'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: order['status'] == 'Arriving Today'
                                        ? Colors.teal
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Product Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: (order['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                order['icon'] as IconData,
                                size: 50,
                                color: order['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Qty: 1',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '₹299',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Delivery Status Timeline
                      const Text(
                        'Delivery Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDeliveryTimeline(order),
                      const SizedBox(height: 20),

                      // Delivery Address
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Asha Nagar Ward 12, Pune - 411001',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Maharashtra, India',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Date
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  order['date'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '₹299',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.track_changes),
                              label: const Text('Track'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: WastecColors.primaryGreen,
                                side: const BorderSide(
                                  color: WastecColors.primaryGreen,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Buy Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WastecColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeline(Map<String, dynamic> order) {
    final isDelivered = order['status'] == 'Delivered';
    
    return Row(
      children: [
        _buildTimelineStep(
          isCompleted: true,
          icon: Icons.shopping_cart,
          label: 'Ordered',
          date: 'Dec 5',
        ),
        Expanded(
          child: Container(
            height: 2,
            color: WastecColors.primaryGreen,
          ),
        ),
        _buildTimelineStep(
          isCompleted: true,
          icon: Icons.local_shipping,
          label: 'Shipped',
          date: 'Dec 10',
        ),
        Expanded(
          child: Container(
            height: 2,
            color: isDelivered ? WastecColors.primaryGreen : Colors.grey[300],
          ),
        ),
        _buildTimelineStep(
          isCompleted: isDelivered,
          icon: Icons.check_circle,
          label: 'Delivered',
          date: isDelivered ? 'Dec 15' : '-',
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required bool isCompleted,
    required IconData icon,
    required String label,
    required String date,
  }) => SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? WastecColors.primaryGreen
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );

  Widget _buildBottomNavBar(BuildContext context) {
    // Eco-Friendly navbar: Home, Eco-Friendly, Track Order, Wallet
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
              // Eco-Friendly
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco,
                        color: WastecColors.mediumGray,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Eco-Friendly',
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
}
