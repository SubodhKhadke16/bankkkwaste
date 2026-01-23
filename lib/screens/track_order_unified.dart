import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wastec_order_card.dart';
import 'home_clean.dart';

/// Unified Track Order Screen with tabs for Waste Bank and Eco-Friendly
class TrackOrderUnifiedScreen extends StatefulWidget {
  const TrackOrderUnifiedScreen({super.key, this.initialTab = 0});

  final int initialTab; // 0 = Waste Bank, 1 = Eco Friendly

  @override
  State<TrackOrderUnifiedScreen> createState() => _TrackOrderUnifiedScreenState();
}

class _TrackOrderUnifiedScreenState extends State<TrackOrderUnifiedScreen> {
  late int _selectedTab;
  bool _showInProgress = true; // For Waste Bank tab

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

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
      body: Column(
        children: [
          // Top Tab Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTopTabButton(
                    label: 'Waste Bank',
                    icon: Icons.recycling,
                    isActive: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopTabButton(
                    label: 'Be Eco Friendly',
                    icon: Icons.eco,
                    isActive: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: _selectedTab == 0 
                ? _buildWasteBankContent() 
                : _buildEcoFriendlyContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );

  Widget _buildTopTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? WastecColors.primaryGreen : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? WastecColors.primaryGreen : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ===== WASTE BANK CONTENT =====
  Widget _buildWasteBankContent() {
    final orders = WastecBankData.orders;
    final inProgressOrders = orders.where((order) => (order['stage']! as int) < 5).toList();
    final completedOrders = orders.where((order) => (order['stage']! as int) >= 5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Book Your New Pickup Card
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

        // Orders Tabs (In Progress / History)
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

        // Orders List
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
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? WastecColors.primaryGreen.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? WastecColors.primaryGreen : Colors.grey[300]!,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isActive ? WastecColors.primaryGreen : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? WastecColors.primaryGreen : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
  Widget _buildEcoFriendlyContent() => SingleChildScrollView(
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
            itemCount: _sampleEcoOrders.length,
            itemBuilder: (context, index) {
              final order = _sampleEcoOrders[index];
              return _buildEcoOrderCard(context, order);
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

  Widget _buildEcoOrderCard(BuildContext context, Map<String, dynamic> order) => GestureDetector(
      onTap: () => _showEcoOrderDetails(context, order),
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

  void _showEcoOrderDetails(BuildContext context, Map<String, dynamic> order) {
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
                                fontWeight: FontWeight.w600,
                                color: order['status'] == 'Arriving Today'
                                    ? Colors.teal
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (order['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          order['icon'] as IconData,
                          size: 40,
                          color: order['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    order['name'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ordered on ${order['date'] as String}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, 'Delivery Address', '123 Green Street, Eco City'),
                  _buildInfoRow(Icons.phone, 'Contact', '+91 98765 43210'),
                  if (order['status'] == 'Arriving Today')
                    _buildInfoRow(Icons.access_time, 'Expected', 'Today by 6:00 PM'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: WastecColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomNavBar(BuildContext context) => Container(
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
              // Home button
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
              Container(
                width: 1,
                height: 35,
                color: Colors.grey.shade300,
              ),
              // Context button (Waste Bank or Eco)
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedTab == 0 ? Icons.recycling : Icons.eco,
                        color: WastecColors.mediumGray,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTab == 0 ? 'Waste Bank' : 'Eco Friendly',
                        style: const TextStyle(
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
