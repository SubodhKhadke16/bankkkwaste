import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/offline_screen.dart';

class WastecBankScreen extends StatefulWidget {
  const WastecBankScreen({Key? key, this.onNavigateToEcoFriendly})
      : super(key: key);

  final VoidCallback? onNavigateToEcoFriendly;

  @override
  State<WastecBankScreen> createState() => _WastecBankScreenState();
}

class _WastecBankScreenState extends State<WastecBankScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();

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
          return Scaffold(
            body: OfflineScreen(onRetry: _checkAndRefresh),
          );
        }
        
        return _buildMainContent(context);
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final topRate = WastecBankData.trendingRates.isNotEmpty
        ? WastecBankData.trendingRates.first
        : null;

    // ensure body has enough bottom padding so content isn't overlapped
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bodyBottomPadding = bottomSafe + kBottomNavigationBarHeight + 12.0;

    return Scaffold(
      body: RefreshIndicator(
        color: WastecColors.primaryGreen,
        onRefresh: () async {
          // Simulate data refresh
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            setState(() {
              // Trigger rebuild to refresh data
            });
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Builder(
        builder: (context) => Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );

  Widget _buildSectionSubtitle(String subtitle) => Builder(
        builder: (context) => Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      );

  Widget _buildHighlightCard({
    required IconData icon,
    required Color tint,
    required String message,
    Color? iconColor,
  }) =>
      Builder(
        builder: (context) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : tint,
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
                  color: WastecColors.primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: iconColor ?? WastecColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // Section A: Trending Rates (Horizontal Scroll)
  Widget _buildTrendingRates(BuildContext context) {
    final rates = [
      {
        'name': 'Paper',
        'price': '₹6/kg',
        'icon': Icons.description,
        'imagePath': 'assets/images/papers.png'
      },
      {
        'name': 'Plastic',
        'price': '₹2/kg',
        'icon': Icons.recycling,
        'imagePath': 'assets/images/plastic.jpg'
      },
      {
        'name': 'Metal',
        'price': '₹17/kg',
        'icon': Icons.hardware,
        'imagePath': 'assets/images/ metal.jpg'
      },
      {
        'name': 'E-Waste',
        'price': '₹10/kg',
        'icon': Icons.devices,
        'imagePath': 'assets/images/ewaste.jpg'
      },
      {
        'name': 'Newspaper',
        'price': '₹7/kg',
        'icon': Icons.newspaper,
        'imagePath': 'assets/images/newspaper.jpg'
      },
      {
        'name': 'Hard Plastic',
        'price': '₹2/kg',
        'icon': Icons.category,
        'imagePath': 'assets/images/hardplastic.avif'
      },
      {
        'name': 'AC (2 Ton)',
        'price': '₹1000/pcs',
        'icon': Icons.ac_unit,
        'imagePath': 'assets/images/ac.jpg'
      },
      {
        'name': 'Iron',
        'price': '₹17/kg',
        'icon': Icons.build,
        'imagePath': 'assets/images/iron.jpg'
      }
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: rates.map((rate) => _WasteMaterialCard(rate: rate)).toList(),
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
      description:
          'Waste partner collected your scrap from the scheduled address.',
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
      description:
          'Material reached the recovery facility for initial screening.',
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
      description:
          'Recycler has received the material and final processing starts.',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? WastecColors.primaryGreen
                          .withOpacity(isCurrent ? 0.16 : 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WastecColors.primaryGreen
                        .withOpacity(isCompleted ? 0.5 : 0.18),
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
                        Icon(stage.icon,
                            size: 18, color: WastecColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stage.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? Colors.black87
                                  : Colors.black87.withOpacity(0.75),
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
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.black45),
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
                        color:
                            Colors.black87.withOpacity(isCompleted ? 0.9 : 0.7),
                      ),
                    ),
                    if (isCurrent && !hasPassed) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
    required this.icon,
    this.location,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      'Paper':
          'Paper waste including newspapers, cardboard, and office paper. Clean and dry paper yields better rates.',
      'Plastic':
          'Recyclable plastic items including bottles, containers, and bags. Sorted plastic commands better prices.',
      'Metal':
          'Scrap metal including aluminum, copper, and steel. High-value recyclable material.',
      'E-Waste':
          'Electronic waste including old phones, computers, and appliances. Contains valuable materials.',
      'Newspaper':
          'Old newspapers and printed media. Highly recyclable material with consistent demand.',
      'Hard Plastic':
          'Hard plastic items like buckets, crates, and containers. Durable and recyclable.',
      'AC (2 Ton)':
          'Old air conditioning units for 2-ton capacity. Requires proper handling and contains valuable components.',
      'Iron':
          'Scrap iron and ferrous metal items. Essential material for the steel industry.',
    };
    return descriptions[materialName] ??
        'Waste material accepted by Wastec Bank for recycling and recovery. Contact us for more details.';
  }
}

class _WasteMaterialCard extends StatelessWidget {

  const _WasteMaterialCard({required this.rate});
  final Map<String, dynamic> rate;

  Product _getProduct() => Product(
      id: rate['name']! as String,
      name: rate['name']! as String,
      price: double.parse(
          (rate['price']! as String).replaceAll(RegExp(r'[^0-9.]'), '')),
      category: 'Waste Bank',
      description: 'Waste material for recycling',
      imageUrl: rate['imagePath'] as String? ?? '',
      stock: 100,
    );

  void _addToCart(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final product = _getProduct();

    cartService.addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: WastecColors.primaryGreen,
      ),
    );
  }

  void _removeFromCart(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final product = _getProduct();

    cartService.removeFromCart(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleCartItem(BuildContext context, bool isInCart) {
    if (isInCart) {
      _removeFromCart(context);
    } else {
      _addToCart(context);
    }
  }

  void _onRateTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteRateDetailPage(rate: rate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onRateTap(context),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: WastecColors.primaryGreen.withOpacity(0.25)),
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
                    : Icon(
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rate['price']! as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: WastecColors.primaryGreen,
                            ),
                          ),
                          Consumer<CartService>(
                            builder: (context, cartService, child) {
                              final product = _getProduct();
                              final isInCart = cartService.isInCart(product.id);

                              return GestureDetector(
                                onTap: () => _toggleCartItem(context, isInCart),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isInCart
                                        ? Colors.red
                                        : WastecColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isInCart ? 'REMOVE' : 'ADD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
