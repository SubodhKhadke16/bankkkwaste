import 'package:flutter/material.dart';

class WastecColors {
  // Brand greens with richer depth for a premium scrap-dealer feel
  static const Color primaryGreen = Color(0xFF0A8C4A);
  static const Color lightGreen = Color(0xFFE4F5EA);
  static const Color darkGreen = Color(0xFF05472A);

  // Warm marketplace-inspired accents
  static const Color accentAmber = Color(0xFFFF8C32);
  static const Color accentCoral = Color(0xFFFF7043);
  static const Color accentTeal = Color(0xFF1FB6A6);

  // Neutral foundation
  static const Color white = Color(0xFFFFFFFF);
  static const Color mistGray = Color(0xFFF3F5F7);
  static const Color mediumGray = Color(0xFF8A8F94);
  static const Color darkGray = Color(0xFF282C34);

  // Status colors
  static const Color errorRed = Color(0xFFEC4A4A);
  static const Color successGreen = Color(0xFF3AB36B);
  static const Color infoBlue = Color(0xFF147AD6);

  static LinearGradient heroGradient = const LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient vibrantMarketplaceGradient = const LinearGradient(
    colors: [primaryGreen, Color(0xFF15A85E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient mutedCardGradient = const LinearGradient(
    colors: [Color(0xFF0FBF61), primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class WastecTheme {
  static ThemeData get lightTheme {
    const baseTextTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: WastecColors.darkGray,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: WastecColors.darkGray,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: WastecColors.darkGray,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: WastecColors.darkGray,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: WastecColors.darkGray,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: WastecColors.mediumGray,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: WastecColors.white,
        letterSpacing: 0.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      primaryColor: WastecColors.primaryGreen,
      scaffoldBackgroundColor: WastecColors.mistGray,
      colorScheme: const ColorScheme.light(
        primary: WastecColors.primaryGreen,
        onPrimary: WastecColors.white,
        secondary: WastecColors.accentAmber,
        onSecondary: WastecColors.white,
        surface: WastecColors.white,
        onSurface: WastecColors.darkGray,
        error: WastecColors.errorRed,
        onError: WastecColors.white,
      ),
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: WastecColors.white,
        foregroundColor: WastecColors.darkGray,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: WastecColors.darkGray,
        ),
      ),
      cardTheme: CardThemeData(
        color: WastecColors.white,
        elevation: 6,
        margin: EdgeInsets.zero,
        shadowColor: WastecColors.darkGreen.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WastecColors.primaryGreen,
          foregroundColor: WastecColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: baseTextTheme.labelLarge,
          shadowColor: WastecColors.darkGreen.withOpacity(0.2),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WastecColors.primaryGreen,
          side: const BorderSide(color: WastecColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: WastecColors.primaryGreen,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WastecColors.white,
        hintStyle: baseTextTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: WastecColors.primaryGreen.withOpacity(0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: WastecColors.primaryGreen.withOpacity(0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WastecColors.primaryGreen, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WastecColors.errorRed, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: WastecColors.lightGreen,
        disabledColor: WastecColors.mistGray,
        selectedColor: WastecColors.primaryGreen.withOpacity(0.12),
        secondarySelectedColor: WastecColors.primaryGreen,
        labelStyle: baseTextTheme.bodyMedium,
        secondaryLabelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: WastecColors.primaryGreen,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: WastecColors.white,
        selectedItemColor: WastecColors.primaryGreen,
        unselectedItemColor: WastecColors.mediumGray,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 22),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: WastecColors.primaryGreen.withOpacity(0.08),
        thickness: 1,
        space: 24,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: WastecColors.primaryGreen,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: WastecColors.darkGray,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          color: WastecColors.mediumGray,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WastecColors.darkGreen,
        contentTextStyle: baseTextTheme.bodyLarge?.copyWith(
          color: WastecColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: WastecColors.accentAmber,
        foregroundColor: WastecColors.white,
        extendedIconLabelSpacing: 12,
      ),
    );
  }

  static ThemeData get darkTheme {
    const baseTextTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: Color(0xFFF5F5F5),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: Color(0xFFF5F5F5),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5F5F5),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF5F5F5),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE0E0E0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFB0B0B0),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: WastecColors.primaryGreen,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: WastecColors.primaryGreen,
        onPrimary: Color(0xFF1A1A1A),
        secondary: WastecColors.accentAmber,
        onSecondary: Color(0xFF1A1A1A),
        surface: Color(0xFF1E1E1E),
        onSurface: Color(0xFFE0E0E0),
        error: WastecColors.errorRed,
        onError: Color(0xFF1A1A1A),
      ),
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE0E0E0),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE0E0E0),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2A2A),
        elevation: 6,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WastecColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: baseTextTheme.labelLarge,
          shadowColor: WastecColors.darkGreen.withOpacity(0.4),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WastecColors.primaryGreen,
          side: const BorderSide(color: WastecColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: WastecColors.primaryGreen,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintStyle: baseTextTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: WastecColors.primaryGreen.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: WastecColors.primaryGreen.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WastecColors.primaryGreen, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: WastecColors.errorRed, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: WastecColors.primaryGreen.withOpacity(0.2),
        disabledColor: const Color(0xFF3A3A3A),
        selectedColor: WastecColors.primaryGreen.withOpacity(0.3),
        secondarySelectedColor: WastecColors.primaryGreen,
        labelStyle: baseTextTheme.bodyMedium,
        secondaryLabelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: WastecColors.primaryGreen,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: WastecColors.primaryGreen,
        unselectedItemColor: Color(0xFF707070),
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 22),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: WastecColors.primaryGreen.withOpacity(0.15),
        thickness: 1,
        space: 24,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: WastecColors.primaryGreen,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          color: Color(0xFFB0B0B0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2A2A),
        contentTextStyle: baseTextTheme.bodyLarge?.copyWith(
          color: const Color(0xFFE0E0E0),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: WastecColors.accentAmber,
        foregroundColor: Color(0xFF1A1A1A),
        extendedIconLabelSpacing: 12,
      ),
    );
  }
}
