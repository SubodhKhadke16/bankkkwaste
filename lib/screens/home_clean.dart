import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/wallet_sync_service.dart';
import '../widgets/cart_icon.dart';
import '../widgets/location_header.dart';
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
    
    // Auto-sync wallet when home screen loads
    _syncWallet();
  }

  Future<void> _syncWallet() async {
    final userId = AuthService().currentUserId;
    if (userId != null) {
      await WalletSyncService.syncCompletedOrders(userId);
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
              const SizedBox(height: 16),
              const _DonateWasteCard(),
              const SizedBox(height: 24),
              const _EnvironmentalImpactSection(),
            ],
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
          const SizedBox(height: 20),

          // Environmental Impact Cards
          _buildEnvironmentalImpact(context),
        ],
      );

  Widget _buildEnvironmentalImpact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environmental Impact',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildImpactCard(
              context,
              title: 'Trees Saved',
              value: '0.0 Trees',
              color: const Color(0xFFE8F5E9),
              icon: Icons.park_outlined,
            ),
            _buildImpactCard(
              context,
              title: 'Air Pollution saved',
              value: '0.0 Kgs of Air',
              color: const Color(0xFFE3F2FD),
              icon: Icons.air_outlined,
            ),
            _buildImpactCard(
              context,
              title: 'Water Pollution saved',
              value: '0.0 Litres of water',
              color: const Color(0xFFE0F2F1),
              icon: Icons.water_drop_outlined,
            ),
            _buildImpactCard(
              context,
              title: 'Land pollution Saved',
              value: '0.0 Sq Mtrs of Land',
              color: const Color(0xFFFFF9C4),
              icon: Icons.terrain_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: WastecColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: WastecColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

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

class _DonateWasteCard extends StatelessWidget {
  const _DonateWasteCard();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donate Waste & Support CSR - Coming Soon!'),
              backgroundColor: WastecColors.primaryGreen,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: Color(0xFFE91E63),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donate Waste & Support CSR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Help communities through waste donation',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 16,
              ),
            ],
          ),
        ),
      );
}

// Top feature cards were removed from Home — moved to Wastec Bank screen.

class _EnvironmentalImpactSection extends StatelessWidget {
  const _EnvironmentalImpactSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environmental Impact',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track positive contribution to the planet',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildImpactGrid(context),
      ],
    );
  }

  Widget _buildImpactGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildImpactCard(
                context,
                title: 'Trees Saved',
                yourValue: '0.0 Trees',
                wastecValue: '0.0 Trees',
                color: const Color(0xFFE8F5E9),
                icon: Icons.park_outlined,
                iconColor: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImpactCard(
                context,
                title: 'Air Pollution saved',
                yourValue: '0.0 Kgs',
                wastecValue: '0.0 Kgs',
                color: const Color(0xFFE3F2FD),
                icon: Icons.air_outlined,
                iconColor: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildImpactCard(
                context,
                title: 'CO2 saved',
                yourValue: '0.0 Kgs',
                wastecValue: '0.0 Kgs',
                color: const Color(0xFFFFF9C4),
                icon: Icons.cloud_outlined,
                iconColor: const Color(0xFFFBC02D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImpactCard(
                context,
                title: 'Water Pollution saved',
                yourValue: '0.0 Litres',
                wastecValue: '0.0 Litres',
                color: const Color(0xFFE0F2F1),
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHorizontalImpactCard(
          context,
          title: 'Land pollution Saved',
          yourValue: '0.0 Sq Mtrs',
          wastecValue: '0.0 Sq Mtrs',
          color: const Color(0xFFFFF3E0),
          icon: Icons.terrain_outlined,
          iconColor: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    BuildContext context, {
    required String title,
    required String yourValue,
    required String wastecValue,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Theme.of(context).dividerColor 
              : color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark 
                  ? iconColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'By you: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                      ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                      : Colors.black54,
                ),
              ),
              Text(
                yourValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? iconColor
                      : iconColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'By Wastec: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                      ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                      : Colors.black54,
                ),
              ),
              Text(
                wastecValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? iconColor.withOpacity(0.7)
                      : iconColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalImpactCard(
    BuildContext context, {
    required String title,
    required String yourValue,
    required String wastecValue,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Theme.of(context).dividerColor 
              : color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                  ? iconColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark 
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'By you: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark 
                            ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                            : Colors.black54,
                      ),
                    ),
                    Text(
                      yourValue,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? iconColor
                            : iconColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'By Wastec: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark 
                            ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                            : Colors.black54,
                      ),
                    ),
                    Text(
                      wastecValue,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? iconColor.withOpacity(0.7)
                            : iconColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
