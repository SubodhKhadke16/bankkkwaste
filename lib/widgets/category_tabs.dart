import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../screens/eco_friendly_page.dart';
import '../screens/scrap_categories_screen.dart';
import '../screens/trending_rates_screen.dart';
import '../screens/wastec_bank_screen.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _CategoryTabTile(config: _CategoryTabConfig.wastecBank),
          _CategoryTabTile(config: _CategoryTabConfig.trendingRates),
          _CategoryTabTile(config: _CategoryTabConfig.scrapCategories),
          _CategoryTabTile(config: _CategoryTabConfig.ecoFriendlyStore),
        ],
      ),
    );
}

class _CategoryTabConfig {
  const _CategoryTabConfig({
    required this.title,
    required this.icon,
    required this.pastelColor,
    required this.textColor,
    required this.accentColor,
    required this.destinationBuilder,
  });

  final String title;
  final IconData icon;
  final Color pastelColor;
  final Color textColor;
  final Color accentColor;
  final WidgetBuilder destinationBuilder;

    static const _CategoryTabConfig wastecBank = _CategoryTabConfig(
      title: 'Waste Bank',
        icon: Icons.recycling,
        pastelColor: Color(0xFFE9F7EF),
        textColor: WastecColors.primaryGreen,
        accentColor: WastecColors.primaryGreen,
      destinationBuilder: _toWastecBank,
      );

    static const _CategoryTabConfig trendingRates = _CategoryTabConfig(
        title: 'Trending Rates',
        icon: Icons.trending_up,
        pastelColor: Color(0xFFFFF7DA),
        textColor: WastecColors.darkGray,
        accentColor: Color(0xFFB87900),
      destinationBuilder: _toTrendingRates,
      );

    static const _CategoryTabConfig scrapCategories = _CategoryTabConfig(
        title: 'Scrap Categories',
        icon: Icons.grid_view_rounded,
        pastelColor: Color(0xFFEFE8FF),
        textColor: Color(0xFF5B3FD4),
        accentColor: Color(0xFF6E4DF4),
      destinationBuilder: _toScrapCategories,
      );

    static const _CategoryTabConfig ecoFriendlyStore = _CategoryTabConfig(
        title: 'Eco-Friendly Store',
        icon: Icons.eco_outlined,
        pastelColor: Color(0xFFD9F7F2),
        textColor: Color(0xFF17897B),
        accentColor: Color(0xFF12A28F),
      destinationBuilder: _toEcoFriendly,
      );

    static Widget _toWastecBank(BuildContext _) => const WastecBankScreen();

    static Widget _toTrendingRates(BuildContext _) => const TrendingRatesScreen();

    static Widget _toScrapCategories(BuildContext _) => const ScrapCategoriesScreen();

    static Widget _toEcoFriendly(BuildContext _) => const EcoFriendlyPage();
}

class _CategoryTabTile extends StatefulWidget {
  const _CategoryTabTile({required this.config});

  final _CategoryTabConfig config;

  @override
  State<_CategoryTabTile> createState() => _CategoryTabTileState();
}

class _CategoryTabTileState extends State<_CategoryTabTile> {
  bool _isPressed = false;

  void _handleHighlight(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: widget.config.destinationBuilder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHighlightChanged: _handleHighlight,
            borderRadius: BorderRadius.circular(24),
            splashFactory: InkRipple.splashFactory,
            splashColor: config.accentColor.withOpacity(0.18),
            highlightColor: Colors.transparent,
            onTap: () => _handleTap(context),
            child: Container(
              width: 136,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: config.pastelColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: config.pastelColor.withOpacity(0.55),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: config.pastelColor.withOpacity(0.9),
                    width: 1.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: config.accentColor.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        config.icon,
                        size: 18,
                        color: config.accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        config.title,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: config.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
