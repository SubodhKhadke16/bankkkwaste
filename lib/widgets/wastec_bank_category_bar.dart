import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../screens/track_order_unified.dart';
import '../screens/trending_rates_screen.dart';
import '../screens/wallet_screen.dart';

class WastecBankCategoryBar extends StatelessWidget {
  const WastecBankCategoryBar({super.key});

  static final List<_WastecCategory> _categories = [
    _WastecCategory(
      label: 'Trending Rates',
      icon: Icons.trending_up,
      background: const Color(0xFFFFF7CE),
      badgeColor: const Color(0xFFFFE59C),
      destinationBuilder: (_) => const TrendingRatesScreen(),
    ),
    _WastecCategory(
      label: 'Track Order',
      icon: Icons.local_shipping,
      background: const Color(0xFFDFF4FF),
      badgeColor: const Color(0xFFBEE6FF),
      destinationBuilder: (_) => const TrackOrderUnifiedScreen(initialTab: 0),
    ),
    _WastecCategory(
      label: 'Wallet',
      icon: Icons.account_balance_wallet,
      background: const Color(0xFFDFFFE8),
      badgeColor: const Color(0xFFBFFFD0),
      destinationBuilder: (_) => const WalletScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final tiles = _categories
              .map((category) => _WastecCategoryTile(category: category))
              .toList();

          if (constraints.maxWidth >= 640) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tiles,
            );
          }

          return SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) => tiles[index],
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: tiles.length,
            ),
          );
        },
      );
}

class _WastecCategory {
  const _WastecCategory({
    required this.label,
    required this.icon,
    required this.background,
    required this.badgeColor,
    required this.destinationBuilder,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color badgeColor;
  final WidgetBuilder destinationBuilder;
}

class _WastecCategoryTile extends StatefulWidget {
  const _WastecCategoryTile({required this.category});

  final _WastecCategory category;

  @override
  State<_WastecCategoryTile> createState() => _WastecCategoryTileState();
}

class _WastecCategoryTileState extends State<_WastecCategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () {
              setState(() => _pressed = false);
              Navigator.of(context).push(
                MaterialPageRoute(builder: widget.category.destinationBuilder),
              );
            },
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            splashColor: widget.category.background.withOpacity(0.35),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 190,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.category.background,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F0C2F),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.category.badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.category.icon,
                        size: 20,
                        color: WastecColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.category.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
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
