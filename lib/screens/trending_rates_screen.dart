import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../data/wastec_bank_data.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wastec_bottom_nav.dart';

class TrendingRatesScreen extends StatelessWidget {
  const TrendingRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rates = WastecBankData.trendingRates;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WastecColors.primaryGreen,
        title: const Text(
          'Trending Rates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: const [ProfileWalletActions()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WastecColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.trending_up, color: WastecColors.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Top movers today: ${rates.first['name']} leads at ${rates.first['price']}.'
                      ' Stay updated with our real-time dealer pricing.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: rates.length,
              itemBuilder: (context, index) {
                final rate = rates[index];
                return _TrendingRateTile(
                  icon: rate['icon']! as IconData,
                  name: rate['name']! as String,
                  price: rate['price']! as String,
                  rank: index + 1,
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WastecColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Updated twice daily based on verified dealer rates across your Wastec Bank network.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: WastecColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WastecBottomNav(
        currentIndex: 0,
        onTap: (index) {
          WastecBottomNav.navigateTo(context, index);
        },
      ),
    );
  }
}

class _TrendingRateTile extends StatelessWidget {
  const _TrendingRateTile({
    required this.icon,
    required this.name,
    required this.price,
    required this.rank,
  });

  final IconData icon;
  final String name;
  final String price;
  final int rank;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: WastecColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: WastecColors.primaryGreen),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: WastecColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: WastecColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: WastecColors.primaryGreen,
              ),
            ),
          ],
        ),
      );
}
