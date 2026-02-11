import 'package:flutter/material.dart';

/// Helper class for theme-aware colors
/// Use this to ensure proper dark theme support across the app
class ThemeHelper {
  /// Get surface color (for cards, containers)
  static Color getSurfaceColor(BuildContext context) => Theme.of(context).cardColor;

  /// Get background color (for scaffolds, main backgrounds)
  static Color getBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  /// Get primary text color
  static Color getTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  /// Get secondary text color (hints, labels)
  static Color getSecondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

  /// Get color for text on primary color backgrounds
  static Color getOnPrimaryColor(BuildContext context) => Theme.of(context).colorScheme.onPrimary;

  /// Get divider color
  static Color getDividerColor(BuildContext context) => Theme.of(context).dividerColor;

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Get adaptive color based on theme
  /// Returns light color in light mode, dark color in dark mode
  static Color getAdaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) => isDarkMode(context) ? darkColor : lightColor;

  /// Get shadow color appropriate for current theme
  static Color getShadowColor(BuildContext context) => isDarkMode(context)
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
}
