import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wastec_bottom_nav.dart';

class ScrapCategoriesScreen extends StatelessWidget {
  const ScrapCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <ScrapCategoryInfo>[
      const ScrapCategoryInfo(
        title: 'Plastics & Polymers',
        description: 'PET bottles, HDPE containers, LDPE wraps, PVC pipes.',
        accentColor: Color(0xFF4F8EF7),
      ),
      const ScrapCategoryInfo(
        title: 'Metals & Alloys',
        description: 'Aluminium sheets, copper wires, brass fittings, steel.',
        accentColor: Color(0xFFFF7043),
      ),
      const ScrapCategoryInfo(
        title: 'Paper & Cardboard',
        description: 'Corrugated boxes, magazines, office paper, newsprint.',
        accentColor: Color(0xFF7E57C2),
      ),
      const ScrapCategoryInfo(
        title: 'E-waste & Components',
        description: 'Motherboards, batteries, cables, mixed e-waste.',
        accentColor: Color(0xFF26A69A),
      ),
      const ScrapCategoryInfo(
        title: 'Glass & Ceramics',
        description: 'Glass bottles, panes, fibreglass, ceramic tiles.',
        accentColor: Color(0xFFFFB74D),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WastecColors.white,
        foregroundColor: WastecColors.darkGray,
        elevation: 0,
        title: const Text('Scrap Categories'),
        actions: const [ProfileWalletActions()],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemBuilder: (context, index) => ScrapCategoryCard(info: categories[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: categories.length,
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

class ScrapCategoryInfo {
  const ScrapCategoryInfo({
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final String title;
  final String description;
  final Color accentColor;
}

class ScrapCategoryCard extends StatelessWidget {
  const ScrapCategoryCard({required this.info, super.key});

  final ScrapCategoryInfo info;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      shadowColor: info.accentColor.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: info.accentColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.category_rounded, color: info.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: WastecColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: WastecColors.mediumGray.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
