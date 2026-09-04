import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Design Tokens & Theme for CarCare
/// Premium, modern, dark, Apple-inspired automotive visual system.
class AppTheme {
  // Layered Dark Backgrounds
  static const Color canvas = Color(0xFF050505);
  static const Color shell = Color(0xFF080808);
  static const Color surface0 = Color(0xFF0D0D0D);
  static const Color surface1 = Color(0xFF111111);
  static const Color surface2 = Color(0xFF151515);
  static const Color surface3 = Color(0xFF1A1A1A);
  static const Color surface4 = Color(0xFF222226);

  // Backward-compatible aliases
  static const Color surface = canvas;
  static const Color card = surface1;

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // CarCare Automotive Brand Accent
  static const Color primary = Color(0xFF16A249);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryGlow = Color(0x2E16A249);

  // Secondary Accent
  static const Color secondary = Color(0xFF38BDF8);

  // Semantic Status Colors
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerGlow = Color(0x26EF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningGlow = Color(0x26F59E0B);
  static const Color success = Color(0xFF16A249);
  static const Color successGlow = Color(0x2616A249);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoGlow = Color(0x263B82F6);

  // Borders & Dividers
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderSubtle = Color(0x0FFFFFFF);
  static const Color borderHighlighted = Color(0x33FFFFFF);
  static const Color borderActive = Color(0x6616A249);

  // Glass Gradients & Shimmers
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x18FFFFFF),
      Color(0x07FFFFFF),
    ],
  );

  static const LinearGradient glassElevatedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x22FFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF16A249),
      Color(0xFF15803D),
    ],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF141416),
      Color(0xFF0F0F10),
    ],
  );

  // Shadows
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black54,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black87,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> primaryGlowShadow = [
    BoxShadow(
      color: Color(0x4016A249),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  /// Premium Dark Automotive ThemeData
  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF14532D),
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface1,
      onSurface: textPrimary,
      error: danger,
      onError: Colors.white,
      brightness: Brightness.dark,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: shell,
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface1,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: border, width: 1),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface1,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface1,
        modalBarrierColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface3,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface1,
        selectedColor: primary.withValues(alpha: 0.2),
        disabledColor: surface0,
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        secondaryLabelStyle:
            const TextStyle(color: primaryLight, fontSize: 13),
        side: const BorderSide(color: border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: shell,
        indicatorColor: primary.withValues(alpha: 0.15),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryLight, size: 24);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: -0.1,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            letterSpacing: -0.1,
          );
        }),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  /// Backward compatibility: light() returns dark theme since CarCare is exclusively dark automotive.
  static ThemeData light() => dark();
}
