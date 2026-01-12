import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wallet_tab.dart';
import '../widgets/location_header.dart';
import 'eco_friendly_page.dart';
import 'wastec_bank_screen.dart';
import 'track_order_screen.dart';
import 'track_order_eco_screen.dart';
// feature screens removed from Home; kept in Wastec Bank screen

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.initialIndex = 0, this.isLoggedIn = false}) : super(key: key);

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
      backgroundColor: WastecColors.white,
      appBar: _buildAppBar(),
      body: _getBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        actions: [ProfileWalletActions(isLoggedIn: widget.isLoggedIn)],
      );
    }
    
    // For Wallet (3), show regular title
    final titles = ['Wastec Bank', 'Be Eco-Friendly', 'Waste Bank', 'Wallet'];
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
      actions: [ProfileWalletActions(isLoggedIn: widget.isLoggedIn)],
    );
  }

  Widget _buildBottomNavigationBar() {
    // When viewing Eco-Friendly (index 1), show a custom navbar with: Home, Eco-Friendly, Track Order, Wallet
    if (_currentIndex == 1) {
      return BottomNavigationBar(
        currentIndex: 1, // Eco-Friendly is at index 1 in this contextual bar
        selectedItemColor: WastecColors.primaryGreen,
        unselectedItemColor: WastecColors.mediumGray,
        onTap: (i) {
          if (i == 0) {
            setState(() => _currentIndex = 0); // Home
          } else if (i == 1) {
            setState(() => _currentIndex = 1); // Eco-Friendly (stays on this tab)
          } else if (i == 2) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const TrackOrderEcoScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          } else if (i == 3) {
            setState(() => _currentIndex = 3); // Wallet
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Eco-Friendly'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Track Order'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        ],
      );
    }

    // When viewing Waste Bank (index 2), show a custom navbar with: Home, Waste Bank, Track Order, Wallet
    if (_currentIndex == 2) {
      return BottomNavigationBar(
        currentIndex: 1, // Waste Bank is at index 1 in this contextual bar
        selectedItemColor: WastecColors.primaryGreen,
        unselectedItemColor: WastecColors.mediumGray,
        onTap: (i) {
          if (i == 0) {
            setState(() => _currentIndex = 0); // Home
          } else if (i == 1) {
            setState(() => _currentIndex = 2); // Waste Bank (stays on this tab)
          } else if (i == 2) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const TrackOrderScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          } else if (i == 3) {
            setState(() => _currentIndex = 3); // Wallet
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Waste Bank'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Track Order'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        ],
      );
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: WastecColors.primaryGreen,
      unselectedItemColor: WastecColors.mediumGray,
      onTap: (i) {
        setState(() => _currentIndex = i);
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_back),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Be Eco-Friendly'),
        BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Waste Bank'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
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
            _ImpactSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                WastecColors.primaryGreen,
                WastecColors.primaryGreen.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: WastecColors.primaryGreen.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 56, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: WastecColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Open Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          const Text(
            'Your Impact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Every bag you send stops waste from hitting landfills.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // CO2 Savings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CO₂ Savings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
                          Icon(Icons.share, size: 16, color: Colors.brown),
                          SizedBox(width: 6),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown,
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
                const Text(
                  'CO₂ reduced by you',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wastec Community Impact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Together, we have reduced:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
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

  Widget _buildBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
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
      Row(
        children: [
          Icon(icon, size: 20, color: WastecColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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

