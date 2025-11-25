import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Swiggy-style category card customized for Wastec Bank
/// Displays a title, subtitle, icon, and action button
class HomeCategoryCard extends StatelessWidget {

  const HomeCategoryCard({
    required this.title, required this.subtitle, required this.icon, required this.onTap, Key? key,
    this.gradient,
    this.iconBackground,
  }) : super(key: key);
  final String title;
  final String subtitle;
  final IconData icon;              
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);
    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: borderRadius,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: gradient ?? WastecColors.mutedCardGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBackground ?? Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: WastecColors.primaryGreen, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.65),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
