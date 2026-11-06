import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Utama (Aviation Deep Navy & Telemetry Teal)
  static const Color primaryNavy = Color(0xFF0F4C81);
  static const Color primaryDark = Color(0xFF092C4C);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color backgroundSky = Color(0xFFF4F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textSlate = Color(0xFF1E293B);

  // Warna Kategori Pastel untuk Kartu Misi
  static const Color pastelMapping = Color(0xFFEFF6FF); // Biru Pastel
  static const Color pastelInspection = Color(0xFFFEF3C7); // Amber Pastel
  static const Color pastelDoc = Color(0xFFECFDF5); // Emerald Pastel

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Pemetaan':
        return pastelMapping;
      case 'Inspeksi':
        return pastelInspection;
      case 'Dokumentasi':
        return pastelDoc;
      default:
        return surfaceWhite;
    }
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryNavy,
      primary: primaryNavy,
      secondary: accentTeal,
      surface: surfaceWhite,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundSky,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textSlate,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
