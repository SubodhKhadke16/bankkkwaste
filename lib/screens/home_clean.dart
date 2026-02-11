import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/cart_icon.dart';
import '../widgets/location_header.dart';
import '../widgets/products_section.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wallet_tab.dart';
import '../widgets/wastec_bottom_nav.dart';
import 'eco_friendly_page.dart';
import 'track_order_unified.dart';
import 'wastec_bank_screen.dart';
// feature screens removed from Home; kept in Wastec Bank screen

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.initialIndex = 0, this.isLoggedIn = false})
      : super(key: key);

  final int initialIndex;
  final bool isLoggedIn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _getBody(),
        bottomNavigationBar: WastecBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },
        ),
      );

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _HomeTab(
          onNavigateToEcoFriendly: () => setState(() => _currentIndex = 1),
          onNavigateToWasteBank: () => setState(() => _currentIndex = 2),
        );
      case 1:
        return EcoFriendlyPage(
          onNavigateToWasteBank: () => setState(() => _currentIndex = 2),
        );
      case 2:
        return WastecBankScreen(
          onNavigateToEcoFriendly: () => setState(() => _currentIndex = 1),
        );
      case 3:
        return const TrackOrderUnifiedScreen(initialTab: 0);
      case 4:
        return const WalletTab();
      default:
        return _HomeTab(
          onNavigateToEcoFriendly: () => setState(() => _currentIndex = 1),
          onNavigateToWasteBank: () => setState(() => _currentIndex = 2),
        );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    // For home (0), eco-friendly (1), and waste bank (2), show LocationHeader instead of title
    if (_currentIndex <= 2) {
      return AppBar(
        elevation: 0,
        backgroundColor: WastecColors.primaryGreen,
        title: const LocationHeader(),
        actions: [
          const CartIcon(),
          ProfileWalletActions(isLoggedIn: widget.isLoggedIn),
        ],
      );
    }

    // For Track Order (3) and Wallet (4), show regular title
    final titles = ['Wastec Bank', 'Be Eco-Friendly', 'Waste Bank', 'Track Order', 'Wallet'];
    return AppBar(
      elevation: 0,
      backgroundColor: WastecColors.primaryGreen,
      title: Text(
        titles[_currentIndex],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        const CartIcon(),
        ProfileWalletActions(isLoggedIn: widget.isLoggedIn),
      ],
    );
  }
}

/// Home Tab Content
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    this.onNavigateToEcoFriendly,
    this.onNavigateToWasteBank,
  });

  final VoidCallback? onNavigateToEcoFriendly;
  final VoidCallback? onNavigateToWasteBank;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _PromoCard(
                          title: 'WASTE BANK',
                          subtitle: 'EARN & RECYCLE',
                          icon: Icons.recycling,
                          onTap: onNavigateToWasteBank,
                        ),
                        const SizedBox(width: 16),
                        _PromoCard(
                          title: 'ECO-FRIENDLY',
                          subtitle: 'SUSTAINABLE LIVING',
                          icon: Icons.eco,
                          onTap: onNavigateToEcoFriendly,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _ImpactSection(),
                    const ProductsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Impact heading
          Text(
            'Your Impact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Every bag you send stops waste from hitting landfills.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // CO2 Savings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CO₂ Savings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: WastecColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share, size: 16, color: WastecColors.primaryGreen),
                          SizedBox(width: 6),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WastecColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '0.00 kg',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: WastecColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CO₂ reduced by you',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildWhiteBadge('Less landfill'),
                    _buildWhiteBadge('Cleaner air'),
                    _buildWhiteBadge('Circular fashion'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Community Impact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wastec Community Impact',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Together, we have reduced:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.eco,
                      size: 32,
                      color: WastecColors.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '42.15 tonnes CO₂',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: WastecColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildImpactPoint(
                      icon: Icons.check_circle,
                      text: 'Waste diverted from landfills',
                    ),
                    const SizedBox(height: 10),
                    _buildImpactPoint(
                      icon: Icons.check_circle,
                      text: 'Materials sent for recycling',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildWhiteBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: WastecColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: WastecColors.primaryGreen,
          ),
        ),
      );

  Widget _buildImpactPoint({
    required IconData icon,
    required String text,
  }) =>
      Builder(
        builder: (context) => Row(
          children: [
            Icon(icon, size: 20, color: WastecColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      );
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: AspectRatio(
          aspectRatio: 1.25,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Top left: Title and Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  // Bottom right: Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      icon,
                      color: Colors.white.withOpacity(0.8),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// Top feature cards were removed from Home — moved to Wastec Bank screen.
