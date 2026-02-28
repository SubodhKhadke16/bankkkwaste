import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/order.dart';
import '../services/connectivity_service.dart';
import '../services/order_service.dart';
import '../services/wallet_sync_service.dart';
import '../widgets/offline_screen.dart';

/// Unified Track Order Screen with tabs for Waste Bank and Eco-Friendly
class TrackOrderUnifiedScreen extends StatefulWidget {
  const TrackOrderUnifiedScreen({
    super.key,
    this.initialTab = 0,
    this.showScaffold = false,
  });

  final int initialTab; // 0 = Waste Bank, 1 = Eco Friendly
  final bool showScaffold; // If false, returns just the body content

  @override
  State<TrackOrderUnifiedScreen> createState() =>
      _TrackOrderUnifiedScreenState();
}

class _TrackOrderUnifiedScreenState extends State<TrackOrderUnifiedScreen> {
  late int _selectedTab;
  int _selectedFilter =
      0; // 0 = All, 1 = Pending, 2 = Confirmed, 3 = Processing, 4 = Delivered
  int _refreshKey = 0; // Key to force FutureBuilder refresh
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _checkAndRefresh() async {
    final isConnected = await _connectivityService.checkConnection();
    if (isConnected) {
      setState(() {
        // Trigger rebuild with connection
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStatus,
      initialData: _connectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        
        if (!isConnected) {
          return widget.showScaffold
              ? Scaffold(
                  appBar: AppBar(
                    title: const Text('Track Order'),
                  ),
                  body: OfflineScreen(onRetry: _checkAndRefresh),
                )
              : OfflineScreen(onRetry: _checkAndRefresh);
        }
        
        return _buildMainContent(context);
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final content = Column(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
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
                          color: _selectedTab == 0
                              ? Colors.white
                              : Colors.grey[600],
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Waste Bank',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.grey[700],
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
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
                          color: _selectedTab == 1
                              ? Colors.white
                              : Colors.grey[600],
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Eco-Friendly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.grey[700],
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
    );

    // If showScaffold is true, wrap in Scaffold with AppBar and bottom nav
    // Otherwise, just return the content for use within HomeScreen
    if (widget.showScaffold) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? filterColors[index].withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? filterColors[index] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? filterColors[index] : Colors.grey[600],
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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Please login to view your waste bank orders'),
          ],
        ),
      );
    }

    // Auto-sync wallet for completed orders
    WalletSyncService.syncCompletedOrders(currentUser.uid);

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
        future: OrderService.getUserWasteBankOrders(currentUser.uid),
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
            orders = orders
                .where((order) => order.status.toLowerCase() == 'pending')
                .toList();
          } else if (_selectedFilter == 2) {
            // Confirmed
            orders = orders
                .where((order) => order.status.toLowerCase() == 'confirmed')
                .toList();
          } else if (_selectedFilter == 3) {
            // Processing/Scheduled
            orders = orders
                .where((order) =>
                    order.status.toLowerCase() == 'scheduled' ||
                    order.status.toLowerCase() == 'processing')
                .toList();
          } else if (_selectedFilter == 4) {
            // Completed
            orders = orders
                .where((order) => order.status.toLowerCase() == 'completed')
                .toList();
          }

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.recycling, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No waste bank orders found'),
                  const SizedBox(height: 8),
                  Text(
                    'Schedule a pickup to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildWasteBankOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildWasteBankOrderCard(BuildContext context, Order order) => GestureDetector(
      onTap: () => _showFirebaseOrderDetails(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.pickupDate != null && order.pickupTimeSlot != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scheduled Pickup',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormat('MMM dd, yyyy').format(order.pickupDate!)} • ${order.pickupTimeSlot}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'scheduled':
        return Colors.purple;
      case 'processing':
        return Colors.amber;
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
            orders = orders
                .where((order) => order.status.toLowerCase() == 'pending')
                .toList();
          } else if (_selectedFilter == 2) {
            // Confirmed
            orders = orders
                .where((order) => order.status.toLowerCase() == 'confirmed')
                .toList();
          } else if (_selectedFilter == 3) {
            // Processing
            orders = orders
                .where((order) => order.status.toLowerCase() == 'processing')
                .toList();
          } else if (_selectedFilter == 4) {
            // Delivered
            orders = orders
                .where((order) => order.status.toLowerCase() == 'delivered')
                .toList();
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search your orders...',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Order history header
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
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

  Widget _buildFirebaseOrderCard(BuildContext context, Order order) =>
      GestureDetector(
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
                  // Pickup Date and Time Slot (for Waste Bank orders)
                  if (order.isWasteBankOrder && order.pickupDate != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event,
                                  size: 16, color: Colors.green[700]),
                              const SizedBox(width: 6),
                              Text(
                                'Scheduled Pickup',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(order.pickupDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          if (order.pickupTimeSlot != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  order.pickupTimeSlot!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Delivery Address (if available)
                  if (order.deliveryAddress != null &&
                      order.deliveryAddress!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
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

  Widget _buildJourneyProgress(Order order) {
    final stages = _getJourneyStages(order.status);
    final currentStageIndex = _getCurrentStageIndex(order.status);
    final isDelivered = order.status.toLowerCase() == 'completed' || 
                        order.status.toLowerCase() == 'delivered';
    
    // Define colors based on delivery status
    final primaryColor = isDelivered ? Colors.green : Colors.orange;
    final lightShade = isDelivered ? Colors.green.shade50 : Colors.orange.shade50;
    final mediumShade = isDelivered ? Colors.green.shade100 : Colors.orange.shade100;
    final borderShade = isDelivered ? Colors.green.shade200 : Colors.orange.shade200;
    final progressBarShade = isDelivered ? Colors.green.shade400 : Colors.orange.shade400;
    final darkShade = isDelivered ? Colors.green.shade700 : Colors.orange.shade700;
    final darkerShade = isDelivered ? Colors.green.shade900 : Colors.orange.shade900;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightShade,
            mediumShade.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderShade),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Journey Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: mediumShade,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentStageIndex + 1} of ${stages.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: darkerShade,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.radio_button_checked, size: 12, color: darkShade),
              const SizedBox(width: 6),
              Text(
                'Current: ${stages[currentStageIndex].title}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: darkerShade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Row(
            children: List.generate(stages.length, (index) {
              final isCompleted = index <= currentStageIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < stages.length - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted ? progressBarShade : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final isCompleted = index < currentStageIndex;
              final isCurrent = index == currentStageIndex;
              final isPending = index > currentStageIndex;
              
              return _buildTimelineItem(
                stage: stage,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPending: isPending,
                isFirst: index == 0,
                isLast: index == stages.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required _JourneyStage stage,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
    required bool isFirst,
    required bool isLast,
  }) {
    final bgColor = isCurrent
        ? Colors.green.shade50
        : isPending
            ? Colors.white
            : Colors.white;
    
    final borderColor = isCurrent
        ? Colors.green.shade300
        : isPending
            ? Colors.grey.shade200
            : Colors.green.shade200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator column
        Column(
          children: [
            // Circle indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent ? Colors.green : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isCurrent ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isCurrent
                          ? stage.icon
                          : stage.icon,
                  size: 16,
                  color: isCompleted || isCurrent ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
            // Vertical line
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      stage.locationIcon,
                      size: 16,
                      color: isCurrent
                          ? Colors.green.shade700
                          : isPending
                              ? Colors.grey.shade500
                              : Colors.green.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        stage.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.grey.shade600 : Colors.black87,
                        ),
                      ),
                    ),
                    if (stage.time != null)
                      Text(
                        stage.time!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        stage.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (stage.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    stage.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                if (isCurrent) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'On the way to the next step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_JourneyStage> _getJourneyStages(String status) {
    return [
      _JourneyStage(
        title: 'Picked',
        location: 'Pickup Point',
        icon: Icons.home_outlined,
        locationIcon: Icons.location_on,
        time: '09:19 AM',
        description: 'Waste partner collected your scrap from the scheduled address',
      ),
      _JourneyStage(
        title: 'Shipped',
        location: 'Transit Hub',
        icon: Icons.local_shipping_outlined,
        locationIcon: Icons.warehouse,
        time: '10:45 AM',
        description: 'Package is on the move to our processing centre',
      ),
      _JourneyStage(
        title: 'Material Recovery Facility',
        location: 'Waste MRF',
        icon: Icons.factory_outlined,
        locationIcon: Icons.business,
        time: '12:30 PM',
        description: 'Material reached the recovery facility for initial screening',
      ),
      _JourneyStage(
        title: 'Segregated',
        location: 'Sorting Facility',
        icon: Icons.sort,
        locationIcon: Icons.compare_arrows,
        time: '02:05 PM',
        description: 'Scrap is sorted into clean batches for recycling partners',
      ),
      _JourneyStage(
        title: 'Shipping',
        location: 'Outbound Logistics',
        icon: Icons.local_shipping,
        locationIcon: Icons.airport_shuttle,
        description: 'Your sorted material is en route to the recycler hub',
      ),
      _JourneyStage(
        title: 'Recycler',
        location: 'Recycler Facility',
        icon: Icons.recycling,
        locationIcon: Icons.eco,
        description: 'Recycler has received the material and final processing starts',
      ),
    ];
  }

  int _getCurrentStageIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
      case 'scheduled':
        return 0; // Picked
      case 'processing':
        return 3; // Segregated
      case 'completed':
      case 'delivered':
        return 5; // Recycler
      default:
        return 0;
    }
  }

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
                  // Journey Progress for Waste Bank orders
                  if (order.isWasteBankOrder) ...[
                    _buildJourneyProgress(order),
                    const SizedBox(height: 24),
                  ],
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
                  // Pickup info for waste bank orders
                  if (order.isWasteBankOrder && order.pickupDate != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scheduled Pickup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(order.pickupDate!),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          if (order.pickupTimeSlot != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  order.pickupTimeSlot!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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

  String _formatDate(DateTime date) =>
      '${date.day} ${_getMonthName(date.month)} ${date.year}';

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
}

class _JourneyStage {
  final String title;
  final String location;
  final IconData icon;
  final IconData locationIcon;
  final String? time;
  final String? description;

  _JourneyStage({
    required this.title,
    required this.location,
    required this.icon,
    required this.locationIcon,
    this.time,
    this.description,
  });
}
