import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../widgets/wastec_order_card.dart';

/// Unified Track Order Screen with tabs for Waste Bank and Eco-Friendly
class TrackOrderUnifiedScreen extends StatefulWidget {
  const TrackOrderUnifiedScreen({super.key, this.initialTab = 0});

  final int initialTab; // 0 = Waste Bank, 1 = Eco Friendly

  @override
  State<TrackOrderUnifiedScreen> createState() => _TrackOrderUnifiedScreenState();
}

class _TrackOrderUnifiedScreenState extends State<TrackOrderUnifiedScreen> {
  late int _selectedTab;
  int _selectedFilter = 0; // 0 = All, 1 = Pending, 2 = Confirmed, 3 = Processing, 4 = Delivered
  int _refreshKey = 0; // Key to force FutureBuilder refresh

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Main Tab Navigation (Bank vs Eco)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = 0;
                      _selectedFilter = 0;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 
                            ? WastecColors.primaryGreen 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.recycling,
                            color: _selectedTab == 0 ? Colors.white : Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Waste Bank',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0 ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = 1;
                      _selectedFilter = 0;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 
                            ? WastecColors.primaryGreen 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco,
                            color: _selectedTab == 1 ? Colors.white : Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Eco-Friendly',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1 ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter Navigation Bar (5 items)
          _buildFilterNavBar(),
          // Content Area
          Expanded(
            child: _selectedTab == 0 
                ? _buildWasteBankContent() 
                : _buildEcoFriendlyContent(),
          ),
        ],
      ),
    );

  // ===== FILTER NAVIGATION BAR =====
  Widget _buildFilterNavBar() {
    final filters = ['All', 'Pending', 'Confirmed', 'Processing', 'Delivered'];
    final filterColors = [
      Colors.grey,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final isSelected = _selectedFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? filterColors[index].withOpacity(0.2) 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? filterColors[index] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? filterColors[index] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ===== WASTE BANK CONTENT =====
  Widget _buildWasteBankContent() {
    final orders = WastecBankData.orders;
    
    // Filter by status based on _selectedFilter
    List<Map<String, dynamic>> filteredOrders;
    if (_selectedFilter == 0) {
      // All orders
      filteredOrders = orders;
    } else if (_selectedFilter == 1) {
      // Pending (stage 0-1)
      filteredOrders = orders.where((order) => (order['stage']! as int) <= 1).toList();
    } else if (_selectedFilter == 2) {
      // Confirmed (stage 2-3)
      filteredOrders = orders.where((order) => (order['stage']! as int) >= 2 && (order['stage']! as int) <= 3).toList();
    } else if (_selectedFilter == 3) {
      // Processing (stage 4)
      filteredOrders = orders.where((order) => (order['stage']! as int) == 4).toList();
    } else {
      // Delivered (stage 5+)
      filteredOrders = orders.where((order) => (order['stage']! as int) >= 5).toList();
    }

    return RefreshIndicator(
      color: WastecColors.primaryGreen,
      onRefresh: () async {
        // Simulate data refresh
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          setState(() {
            // Trigger rebuild to refresh orders
          });
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Active Orders List
          filteredOrders.isEmpty
              ? _buildEmptyState('No Orders', 'No orders found for this filter')
              : Column(
                  children: filteredOrders.map((order) => _buildSimplifiedOrderCard(context, order)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedOrderCard(BuildContext context, Map<String, dynamic> order) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WastecOrderCard(order: order),
    );

  Widget _buildEmptyState(String title, String message) => Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );

  void _showDetailedOrderDialog(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: _buildOrderDetailsContent(order),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(Map<String, dynamic> order) {
    final currentStage = order['stage'] as int;
    final orderId = order['id'] as String;
    final date = order['date'] as String;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order $orderId',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled for $date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: currentStage >= 5 ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: currentStage >= 5 ? Colors.green : Colors.orange,
                  ),
                ),
                child: Text(
                  currentStage >= 5 ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: currentStage >= 5 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildOrderTimeline(currentStage),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(int currentStage) {
    final stages = [
      {'title': 'Order Placed', 'subtitle': 'We received your request'},
      {'title': 'Pickup Scheduled', 'subtitle': 'Agent assigned'},
      {'title': 'Agent on the Way', 'subtitle': 'Coming to your location'},
      {'title': 'Materials Collected', 'subtitle': 'Scrap picked up'},
      {'title': 'At Facility', 'subtitle': 'Being processed'},
      {'title': 'Completed', 'subtitle': 'Payment credited'},
    ];

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentStage;
        final isCurrent = index == currentStage;
        final stage = stages[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent ? WastecColors.primaryGreen : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? WastecColors.primaryGreen : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: isCompleted ? 16 : 8,
                  ),
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted ? WastecColors.primaryGreen : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted || isCurrent ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage['subtitle']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===== ECO-FRIENDLY CONTENT =====
  Widget _buildEcoFriendlyContent() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Please login to view your orders'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: WastecColors.primaryGreen,
      onRefresh: () async {
        // Trigger rebuild to refresh orders from Firebase
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            // Increment key to force FutureBuilder to rebuild with fresh data
            _refreshKey++;
          });
        }
      },
      child: FutureBuilder<List<Order>>(
        key: ValueKey(_refreshKey), // Use key to force rebuild on refresh
        future: OrderService.getUserOrders(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          var orders = snapshot.data ?? [];
          
          // Filter by status based on _selectedFilter
          if (_selectedFilter == 1) {
            // Pending
            orders = orders.where((order) => order.status.toLowerCase() == 'pending').toList();
          } else if (_selectedFilter == 2) {
            // Confirmed
            orders = orders.where((order) => order.status.toLowerCase() == 'confirmed').toList();
          } else if (_selectedFilter == 3) {
            // Processing
            orders = orders.where((order) => order.status.toLowerCase() == 'processing').toList();
          } else if (_selectedFilter == 4) {
            // Delivered
            orders = orders.where((order) => order.status.toLowerCase() == 'delivered').toList();
          }

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No orders found'),
                  const SizedBox(height: 8),
                  Text(
                    'No orders match this filter',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                // Search bar
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
                    '${orders.length} order${orders.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                // Orders list from Firebase
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildFirebaseOrderCard(context, order);
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
          );
        },
      ),
    );
  }

  Widget _buildFirebaseOrderCard(BuildContext context, Order order) => GestureDetector(
        onTap: () => _showFirebaseOrderDetails(context, order),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Delivery Address (if available)
                  if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.deliveryAddress!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Items count
                  Text(
                    '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Amount
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _showFirebaseOrderDetails(BuildContext context, Order order) {
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Order header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 12).toUpperCase()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Items
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  // Delivery info
                  if (order.deliveryAddress != null) ...[
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.deliveryAddress!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (order.phoneNumber != null) ...[
                    const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.phoneNumber!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WastecColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static final List<Map<String, dynamic>> _sampleEcoOrders = [
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
}
