import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand accents - dynamically bound to active theme preset
  static Color get primary => AppTheme.currentPreset.primaryColor;
  static Color get primaryLight => AppTheme.currentPreset.primaryLight;
  static Color get primaryDark => AppTheme.currentPreset.primaryDark;
  static const Color secondary = Color(0xFF0EA5E9); // Radiant Sky / Oceanic Teal
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color accent = Color(0xFFF43F5E); // Coral Rose
  static const Color accentWarm = Color(0xFFF59E0B); // Amber Gold
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Dark palette - dynamically bound to active theme preset
  static Color get darkBackground => AppTheme.currentPreset.darkBackground;
  static Color get darkSurface => AppTheme.currentPreset.darkSurface;
  static Color get darkSurfaceCard => AppTheme.currentPreset.darkSurfaceCard;
  static const Color darkSurfaceCardHigh = Color(0xFF22314E);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkSubtext = Color(0xFF94A3B8);

  // Light palette - dynamically bound to active theme preset
  static Color get lightBackground => AppTheme.currentPreset.lightBackground;
  static Color get lightSurface => AppTheme.currentPreset.lightSurface;
  static Color get lightSurfaceCard => AppTheme.currentPreset.lightSurfaceCard;
  static const Color lightSurfaceCardHigh = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightSubtext = Color(0xFF64748B);
}

/// Represents one of the 10 system themes that can apply across the entire app
class AppThemePreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color primaryLight;
  final Color primaryDark;
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceCard;
  final Color lightBackground;
  final Color lightSurface;
  final Color lightSurfaceCard;
  final String styleDescription;
  final bool isFree;
  final String? preferredMode; // 'dark', 'light', or null
  final bool isAmoled;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.primaryLight,
    required this.primaryDark,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceCard,
    required this.lightBackground,
    required this.lightSurface,
    required this.lightSurfaceCard,
    required this.styleDescription,
    this.isFree = false,
    this.preferredMode,
    this.isAmoled = false,
  });
}

class AppTheme {
  // 10 Official Themes:
  // Free: Ocean Blue, Minimal Light, Midnight Dark
  // Plan 89 (Gold Plan): Remaining 7 themes
  static const List<AppThemePreset> presets = [
    // --- FREE THEMES ---
    AppThemePreset(
      id: 'ocean_blue',
      name: 'Ocean Blue',
      primaryColor: Color(0xFF1677FF),
      primaryLight: Color(0xFF3B82F6),
      primaryDark: Color(0xFF1D4ED8),
      darkBackground: Color(0xFF0B0F19),
      darkSurface: Color(0xFF131D31),
      darkSurfaceCard: Color(0xFF1A263E),
      lightBackground: Color(0xFFF8FAFC),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFF1F5F9),
      styleDescription: 'Professional, clean, modern',
      isFree: true,
    ),
    AppThemePreset(
      id: 'minimal_light',
      name: 'Minimal Light',
      primaryColor: Color(0xFF475569),
      primaryLight: Color(0xFF64748B),
      primaryDark: Color(0xFF334155),
      darkBackground: Color(0xFF0F172A),
      darkSurface: Color(0xFF1E293B),
      darkSurfaceCard: Color(0xFF334155),
      lightBackground: Color(0xFFF8FAFC),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFF1F5F9),
      styleDescription: 'Simple, clean, distraction-free',
      isFree: true,
      preferredMode: 'light',
    ),
    AppThemePreset(
      id: 'midnight_dark',
      name: 'Midnight Dark',
      primaryColor: Color(0xFF8B5CF6),
      primaryLight: Color(0xFFA78BFA),
      primaryDark: Color(0xFF7C3AED),
      darkBackground: Color(0xFF090614),
      darkSurface: Color(0xFF140D2B),
      darkSurfaceCard: Color(0xFF1E143E),
      lightBackground: Color(0xFFF5F3FF),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFEDE9FE),
      styleDescription: 'Premium dark with purple accents',
      isFree: true,
      preferredMode: 'dark',
    ),

    // --- GOLD PLAN (₹89) THEMES ---
    AppThemePreset(
      id: 'lavender_dream',
      name: 'Lavender Dream',
      primaryColor: Color(0xFF7C3AED),
      primaryLight: Color(0xFF8B5CF6),
      primaryDark: Color(0xFF6D28D9),
      darkBackground: Color(0xFF0F0B1E),
      darkSurface: Color(0xFF191233),
      darkSurfaceCard: Color(0xFF261B4D),
      lightBackground: Color(0xFFFAF8FF),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFF3E8FF),
      styleDescription: 'Soft, elegant, calming',
      isFree: false,
    ),
    AppThemePreset(
      id: 'emerald_focus',
      name: 'Emerald Focus',
      primaryColor: Color(0xFF059669),
      primaryLight: Color(0xFF10B981),
      primaryDark: Color(0xFF047857),
      darkBackground: Color(0xFF05140D),
      darkSurface: Color(0xFF0C2419),
      darkSurfaceCard: Color(0xFF143828),
      lightBackground: Color(0xFFF0FDF4),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFDCFCE7),
      styleDescription: 'Peaceful, study-focused',
      isFree: false,
    ),
    AppThemePreset(
      id: 'sunset_glow',
      name: 'Sunset Glow',
      primaryColor: Color(0xFFEA580C),
      primaryLight: Color(0xFFF97316),
      primaryDark: Color(0xFFC2410C),
      darkBackground: Color(0xFF150B06),
      darkSurface: Color(0xFF27150C),
      darkSurfaceCard: Color(0xFF3B2012),
      lightBackground: Color(0xFFFFF7ED),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFFFEDD5),
      styleDescription: 'Warm, vibrant, energetic',
      isFree: false,
    ),
    AppThemePreset(
      id: 'rose_pink',
      name: 'Rose Pink',
      primaryColor: Color(0xFFDB2777),
      primaryLight: Color(0xFFEC4899),
      primaryDark: Color(0xFFBE185D),
      darkBackground: Color(0xFF170610),
      darkSurface: Color(0xFF280B1E),
      darkSurfaceCard: Color(0xFF3D122F),
      lightBackground: Color(0xFFFDF2F8),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFFCE7F3),
      styleDescription: 'Playful, stylish, friendly',
      isFree: false,
    ),
    AppThemePreset(
      id: 'amoled_black',
      name: 'AMOLED Black',
      primaryColor: Color(0xFF06B6D4),
      primaryLight: Color(0xFF22D3EE),
      primaryDark: Color(0xFF0891B2),
      darkBackground: Color(0xFF000000),
      darkSurface: Color(0xFF0D0D0D),
      darkSurfaceCard: Color(0xFF171717),
      lightBackground: Color(0xFFF8FAFC),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFF1F5F9),
      styleDescription: 'Pure black with cyan accents',
      isFree: false,
      preferredMode: 'dark',
      isAmoled: true,
    ),
    AppThemePreset(
      id: 'royal_purple',
      name: 'Royal Purple',
      primaryColor: Color(0xFF6D28D9),
      primaryLight: Color(0xFF7C3AED),
      primaryDark: Color(0xFF5B21B6),
      darkBackground: Color(0xFF0C0617),
      darkSurface: Color(0xFF170D2C),
      darkSurfaceCard: Color(0xFF251545),
      lightBackground: Color(0xFFFAF5FF),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFF3E8FF),
      styleDescription: 'Premium, bold, sophisticated',
      isFree: false,
    ),
    AppThemePreset(
      id: 'mint_fresh',
      name: 'Mint Fresh',
      primaryColor: Color(0xFF0D9488),
      primaryLight: Color(0xFF14B8A6),
      primaryDark: Color(0xFF0F766E),
      darkBackground: Color(0xFF041412),
      darkSurface: Color(0xFF092522),
      darkSurfaceCard: Color(0xFF103A36),
      lightBackground: Color(0xFFF0FDFA),
      lightSurface: Color(0xFFFFFFFF),
      lightSurfaceCard: Color(0xFFCCFBF1),
      styleDescription: 'Fresh, light, refreshing',
      isFree: false,
    ),
  ];

  static AppThemePreset _currentPreset = presets.first;
  static AppThemePreset get currentPreset => _currentPreset;

  static void applyPreset(AppThemePreset preset) {
    _currentPreset = preset;
  }

  static AppThemePreset getPreset(String? id) {
    if (id == null) return presets.first;
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets.first,
    );
  }

  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();

  static ThemeData getLightTheme([dynamic presetOrAccent, bool isAmoled = false]) {
    final AppThemePreset preset = presetOrAccent is AppThemePreset
        ? presetOrAccent
        : (presetOrAccent is Color
            ? presets.firstWhere((p) => p.primaryColor == presetOrAccent, orElse: () => currentPreset)
            : currentPreset);

    final primary = preset.primaryColor;
    final scaffoldBg = preset.lightBackground;
    final surfaceColor = preset.lightSurface;
    final surfaceCardColor = preset.lightSurfaceCard;
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surfaceColor,
        primary: primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightText),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scaffoldBg,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
          }
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightSubtext);
        }),
      ),
    );
  }

  static ThemeData getDarkTheme([dynamic presetOrAccent, bool isAmoled = false]) {
    final AppThemePreset preset = presetOrAccent is AppThemePreset
        ? presetOrAccent
        : (presetOrAccent is Color
            ? presets.firstWhere((p) => p.primaryColor == presetOrAccent, orElse: () => currentPreset)
            : currentPreset);

    final primary = preset.primaryColor;
    final scaffoldBg = preset.darkBackground;
    final surfaceColor = preset.darkSurface;
    final surfaceCardColor = preset.darkSurfaceCard;
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: surfaceColor,
        primary: primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scaffoldBg,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
          }
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkSubtext);
        }),
      ),
    );
  }
}
