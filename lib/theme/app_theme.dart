// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData _base(ColorScheme scheme) {
    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: scheme.onBackground,
      displayColor: scheme.onBackground,
    );
    return ThemeData(
      colorScheme: scheme,
      textTheme: textTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
        centerTitle: false,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData get light => _base(
        const ColorScheme.light(
          primary: Color(0xFF2B5BFE),
          surface: Color(0xFFF9FAFB),
          background: Color(0xFFF6F7F8),
        ),
      );

  static ThemeData get dark => _base(
        const ColorScheme.dark(
          primary: Color(0xFF5E86FF),
          surface: Color(0xFF111317),
          background: Color(0xFF0C0E12),
        ),
      );
}
