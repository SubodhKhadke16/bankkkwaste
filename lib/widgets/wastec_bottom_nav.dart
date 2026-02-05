import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/home_clean.dart';
import '../screens/eco_friendly_page.dart';
import '../screens/wastec_bank_screen.dart';
import '../screens/track_order_unified.dart';
import '../widgets/wallet_tab.dart';

/// Reusable bottom navigation bar for Wastec app
/// 
/// Usage: WastecBottomNav(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
/// )
class WastecBottomNav extends StatelessWidget {
  const WastecBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: WastecColors.primaryGreen,
      unselectedItemColor: WastecColors.mediumGray,
      onTap: (i) => onTap(i),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco),
          label: 'Eco-Friendly',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.recycling),
          label: 'Waste Bank',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Track Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Wallet',
        ),
      ],
    );
  }

  /// Helper method to navigate to appropriate screen based on index
  static void navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EcoFriendlyPage()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WastecBankScreen()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const TrackOrderUnifiedScreen(initialTab: 0),
          ),
          (route) => false,
        );
        break;
      case 4:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WalletTab()),
          (route) => false,
        );
        break;
    }
  }
}
