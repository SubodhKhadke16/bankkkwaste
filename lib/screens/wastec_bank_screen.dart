import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../widgets/location_header.dart';
import '../widgets/quick_access_row.dart';
import 'eco_friendly_page.dart';

class WastecBankScreen extends StatelessWidget {
  const WastecBankScreen({Key? key, this.onNavigateToEcoFriendly}) : super(key: key);

  final VoidCallback? onNavigateToEcoFriendly;

  @override
  Widget build(BuildContext context) {
    final topRate = WastecBankData.trendingRates.isNotEmpty
        ? WastecBankData.trendingRates.first
        : null;

    // ensure body has enough bottom padding so content isn't overlapped
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bodyBottomPadding = bottomSafe + kBottomNavigationBarHeight + 12.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuickAccessRow(
                  current: QuickNavTarget.wasteBank,
                  onNavigateToWasteBank: null,
                  onNavigateToEcoFriendly: onNavigateToEcoFriendly ?? () {},
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, bodyBottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section A: Trending Rates
                      _buildSectionTitle('Trending Rates'),
                      _buildSectionSubtitle(
                          'These rates are provided by Wastec Bank dealers in your area.'),
                      const SizedBox(height: 12),
                      if (topRate != null)
                        _buildHighlightCard(
                          icon: Icons.insights_outlined,
                          tint: const Color(0xFFFFF4DA),
                          message:
                              'Top rate today: ${topRate['name']} at ${topRate['price']} · Updated live from trusted dealers.',
                        ),
                      const SizedBox(height: 12),
                      _buildTrendingRates(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
}  Widget _buildSectionTitle(String title) => Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );

  Widget _buildSectionSubtitle(String subtitle) => Text(
      subtitle,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    );

  Widget _buildHighlightCard({
    required IconData icon,
    required Color tint,
    required String message,
    Color? iconColor,
  }) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? WastecColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  // Section A: Trending Rates (Horizontal Scroll)
  Widget _buildTrendingRates(BuildContext context) {
    final rates = [
      {'name': 'Paper', 'price': '₹6/kg', 'icon': Icons.description, 'imagePath':'assets/images/papers.png'},
      {'name': 'Plastic', 'price': '₹2/kg', 'icon': Icons.recycling},
      {'name': 'Metal', 'price': '₹17/kg', 'icon': Icons.hardware},
      {'name': 'E-Waste', 'price': '₹10/kg', 'icon': Icons.devices},
      {'name': 'Newspaper', 'price': '₹7/kg', 'icon': Icons.newspaper},
      {'name': 'Hard Plastic', 'price': '₹2/kg', 'icon': Icons.category},
      {'name': 'AC (2 Ton)', 'price': '₹1000/pcs', 'icon': Icons.ac_unit},
      {'name': 'Iron', 'price': '₹17/kg', 'icon': Icons.build},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: rates.map((rate) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onRateTap(context, rate),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: WastecColors.primaryGreen.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      color: WastecColors.lightGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: rate['imagePath'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                            child: Image.asset(
                              rate['imagePath']! as String,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                    
                    :Icon(
                      rate['icon']! as IconData,
                      color: WastecColors.primaryGreen,
                      size: 48,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              rate['name']! as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rate['price']! as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: WastecColors.primaryGreen,
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
        )).toList(),
    );
  }

  void _onRateTap(BuildContext context, Map<String, dynamic> rate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteRateDetailPage(rate: rate),
      ),
    );
  }

  // Section B: Track Your Orders (Vertical List)
  Widget _buildOrdersList() {
    final orders = [
      {
        'id': '#WSTC1234',
        'status': 'In Transit',
        'eta': 'Arrives by 04:30 PM',
        'lastUpdate': 'Updated 12 mins ago',
        'date': '10 Nov 2025',
        'payment': '₹450 • COD',
        'weight': '19.4 kg total',
        'notes': 'Mixed plastic & corrugated cardboard',
        'pickup': 'Asha Nagar Ward 12, Pune',
        'drop': 'Eco Recovery Hub, Sector 4',
        'agent': 'Rahul Sharma',
        'vehicle': 'Mini Truck • MH12 AB 4589',
        'contact': '+91 98765 43210',
        'icon': Icons.local_shipping,
        'color': Colors.deepOrange,
        'stage': 3,
        'timeline': const <String?>[
          '09:10 AM',
          '10:45 AM',
          '12:30 PM',
          '02:05 PM',
          null,
          null,
        ],
      },
      {
        'id': '#WSTC1235',
        'status': 'Ready for Recycling',
        'eta': 'Completed 05:45 PM',
        'lastUpdate': 'Closed 1 day ago',
        'date': '08 Nov 2025',
        'payment': '₹320 • Wallet',
        'weight': '11.2 kg total',
        'notes': 'Aluminium cans sorted at pickup',
        'pickup': 'Nav Jeevan Society, Pune',
        'drop': 'Green Loop Recycler, Chakan',
        'agent': 'Wastec Fleet 07',
        'vehicle': 'EV Van • MH12 CL 9087',
        'contact': '+91 91345 77654',
        'icon': Icons.verified,
        'color': Colors.teal,
        'stage': 5,
        'timeline': const <String?>[
          '08:20 AM',
          '09:40 AM',
          '11:10 AM',
          '01:55 PM',
          '04:00 PM',
          '05:45 PM',
        ],
      },
      {
        'id': '#WSTC1236',
        'status': 'Picked Up',
        'eta': 'Sorting starts by 01:00 PM',
        'lastUpdate': 'Driver departed 25 mins ago',
        'date': '11 Nov 2025',
        'payment': '₹580 • Online',
        'weight': '23.0 kg total',
        'notes': 'Glass items packed separately',
        'pickup': 'Skyline Residency, Baner',
        'drop': 'Wastec Material Hub, Wakad',
        'agent': 'Priya Kulkarni',
        'vehicle': 'Loader Bike • MH14 XY 3344',
        'contact': '+91 96543 22109',
        'icon': Icons.local_shipping,
        'color': Colors.amber[800],
        'stage': 1,
        'timeline': const <String?>[
          '09:35 AM',
          '11:00 AM',
          null,
          null,
          null,
          null,
        ],
      },
    ];

    return Column(
      children: orders.map((order) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WastecColors.primaryGreen.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (order['color']! as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      order['icon']! as IconData,
                      color: order['color']! as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order ${order['id']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (order['color']! as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order['status']! as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: order['color']! as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['eta']! as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WastecColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order['lastUpdate']! as String,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.monitor_weight_outlined,
                      label: order['weight']! as String,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.payments_outlined,
                      label: order['payment']! as String,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RouteStops(
                pickup: order['pickup']! as String,
                drop: order['drop']! as String,
                notes: order['notes']! as String,
              ),
              const SizedBox(height: 18),
              _DriverCard(
                name: order['agent']! as String,
                vehicle: order['vehicle']! as String,
                contact: order['contact']! as String,
              ),
              const SizedBox(height: 18),
              _DeliveryProgress(stage: order['stage']! as int),
              const SizedBox(height: 20),
              _OrderTimeline(
                currentStage: order['stage']! as int,
                timeline: order['timeline']! as List<String?>,
              ),
            ],
          ),
        )).toList(),
    );
  }

  // Section C: Profile & Settings (List Tiles)
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.currentStage, required this.timeline});

  final int currentStage;
  final List<String?> timeline;

  static int get stageCount => _stages.length;

  static _OrderStage stageAt(int index) {
    final safeIndex = index.clamp(0, _stages.length - 1).toInt();
    return _stages[safeIndex];
  }

  static final List<_OrderStage> _stages = [
    const _OrderStage(
      label: 'Picked',
      description: 'Waste partner collected your scrap from the scheduled address.',
      location: 'Pickup Point',
      icon: Icons.person_pin_circle_outlined,
    ),
    const _OrderStage(
      label: 'Shipped',
      description: 'Package is on the move to our processing centre.',
      location: 'Transit Hub',
      icon: Icons.local_shipping_outlined,
    ),
    const _OrderStage(
      label: 'Material Recovery Facility',
      description: 'Material reached the recovery facility for initial screening.',
      location: 'Wastec MRF',
      icon: Icons.factory_outlined,
    ),
    const _OrderStage(
      label: 'Segregated',
      description: 'Scrap is sorted into clean batches for recycling partners.',
      location: 'Sorting Line 3',
      icon: Icons.category_outlined,
    ),
    const _OrderStage(
      label: 'Shipping',
      description: 'Your sorted material is en route to the recycler hub.',
      location: 'Outbound Logistics',
      icon: Icons.directions_boat_outlined,
    ),
    const _OrderStage(
      label: 'Recycler',
      description: 'Recycler has received the material and final processing starts.',
      location: 'Recycler Facility',
      icon: Icons.recycling,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeStage = currentStage < 0
        ? 0
        : currentStage >= _stages.length
            ? _stages.length - 1
            : currentStage;

    final stageTimes = List<String?>.generate(_stages.length, (index) {
      if (index < timeline.length) {
        return timeline[index];
      }
      return null;
    });

    return Column(
      children: List.generate(_stages.length, (index) {
        final stage = _stages[index];
        final isCompleted = index <= activeStage;
        final isCurrent = index == activeStage;
        final hasPassed = index < activeStage;
        final timeLabel = stageTimes[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineNode(
              isFirst: index == 0,
              isLast: index == _stages.length - 1,
              upperActive: isCompleted,
              lowerActive: hasPassed,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: index == _stages.length - 1 ? 0 : 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? WastecColors.primaryGreen.withOpacity(isCurrent ? 0.16 : 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WastecColors.primaryGreen.withOpacity(isCompleted ? 0.5 : 0.18),
                  ),
                  boxShadow: [
                    if (isCompleted)
                      BoxShadow(
                        color: WastecColors.primaryGreen.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(stage.icon, size: 18, color: WastecColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stage.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  isCompleted ? Colors.black87 : Colors.black87.withOpacity(0.75),
                            ),
                          ),
                        ),
                        if (timeLabel != null)
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (stage.location != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                stage.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      stage.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.black87.withOpacity(isCompleted ? 0.9 : 0.7),
                      ),
                    ),
                    if (isCurrent && !hasPassed) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: WastecColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'On the way to the next stop',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WastecColors.primaryGreen,
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
      }),
    );
  }
}

class _OrderStage {
  const _OrderStage({
    required this.label,
    required this.description,
    required this.icon, this.location,
  });

  final String label;
  final String description;
  final String? location;
  final IconData icon;
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.isFirst,
    required this.isLast,
    required this.upperActive,
    required this.lowerActive,
    required this.isCompleted,
    required this.isCurrent,
  });

  final bool isFirst;
  final bool isLast;
  final bool upperActive;
  final bool lowerActive;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    const double lineWidth = 2;
    const activeColor = WastecColors.primaryGreen;
    final inactiveColor = activeColor.withOpacity(0.2);

    final dotFill = isCompleted ? activeColor : Colors.white;
    final dotBorder = isCompleted ? activeColor : activeColor.withOpacity(0.5);

    return SizedBox(
      width: 28,
      child: Column(
        children: [
          if (!isFirst)
            Container(
              width: lineWidth,
              height: 18,
              color: upperActive ? activeColor : inactiveColor,
            ),
          Container(
            width: isCurrent ? 20 : 18,
            height: isCurrent ? 20 : 18,
            decoration: BoxDecoration(
              color: dotFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? activeColor : dotBorder,
                width: isCurrent ? 3 : 2,
              ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  )
                : null,
          ),
          if (!isLast)
            Container(
              width: lineWidth,
              height: 26,
              color: lowerActive ? activeColor : inactiveColor,
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: WastecColors.lightGreen.withOpacity(0.22),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: WastecColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
}

class _RouteStops extends StatelessWidget {
  const _RouteStops({required this.pickup, required this.drop, required this.notes});

  final String pickup;
  final String drop;
  final String notes;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WastecColors.primaryGreen.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoutePoint(
              title: 'Pickup',
              detail: pickup,
              icon: Icons.store_mall_directory_outlined,
              accent: WastecColors.primaryGreen,
            ),
            const _RouteDivider(),
            _RoutePoint(
              title: 'Drop-off',
              detail: drop,
              icon: Icons.location_city_outlined,
              accent: Colors.deepOrangeAccent,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WastecColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sticky_note_2_outlined,
                      size: 16, color: WastecColors.primaryGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _RouteDivider extends StatelessWidget {
  const _RouteDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 17),
              width: 2,
              height: 28,
              decoration: BoxDecoration(
                color: WastecColors.primaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
          ],
        ),
      );
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.name, required this.vehicle, required this.contact});

  final String name;
  final String vehicle;
  final String contact;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WastecColors.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WastecColors.primaryGreen.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.delivery_dining, color: WastecColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call Driver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WastecColors.primaryGreen,
                      side: const BorderSide(color: WastecColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WastecColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _DeliveryProgress extends StatelessWidget {
  const _DeliveryProgress({required this.stage});

  final int stage;

  @override
  Widget build(BuildContext context) {
    final safeStage = stage.clamp(0, _OrderTimeline.stageCount - 1);
    final completedSteps = safeStage + 1;
    final progress = completedSteps / _OrderTimeline.stageCount;
    final currentStage = _OrderTimeline.stageAt(safeStage).label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Journey Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              '$completedSteps of ${_OrderTimeline.stageCount} stages',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: WastecColors.lightGreen.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(WastecColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Current milestone: $currentStage',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

/// Detail page for waste material rates
class WasteRateDetailPage extends StatelessWidget {
  const WasteRateDetailPage({required this.rate, super.key});

  final Map<String, dynamic> rate;

  @override
  Widget build(BuildContext context) {
    final name = rate['name'] as String? ?? 'Unknown';
    final price = rate['price'] as String? ?? 'N/A';
    final imagePath = rate['imagePath'] as String?;
    final icon = rate['icon'] as IconData? ?? Icons.info_outline;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image or icon
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: WastecColors.lightGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: WastecColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 80,
                        color: WastecColors.primaryGreen,
                      ),
              ),
              const SizedBox(height: 24),

              // Material name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Current rate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: WastecColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: WastecColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Current Rate:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: WastecColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Information section
              const Text(
                'About this material',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Text(
                  _getMaterialDescription(name),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Call to action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule pickup for $name'),
                        backgroundColor: WastecColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WastecColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Schedule Pickup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

  String _getMaterialDescription(String materialName) {
    final descriptions = {
      'Paper': 'Paper waste including newspapers, cardboard, and office paper. Clean and dry paper yields better rates.',
      'Plastic': 'Recyclable plastic items including bottles, containers, and bags. Sorted plastic commands better prices.',
      'Metal': 'Scrap metal including aluminum, copper, and steel. High-value recyclable material.',
      'E-Waste': 'Electronic waste including old phones, computers, and appliances. Contains valuable materials.',
      'Newspaper': 'Old newspapers and printed media. Highly recyclable material with consistent demand.',
      'Hard Plastic': 'Hard plastic items like buckets, crates, and containers. Durable and recyclable.',
      'AC (2 Ton)': 'Old air conditioning units for 2-ton capacity. Requires proper handling and contains valuable components.',
      'Iron': 'Scrap iron and ferrous metal items. Essential material for the steel industry.',
    };
    return descriptions[materialName] ?? 'Waste material accepted by Wastec Bank for recycling and recovery. Contact us for more details.';
  }
}


