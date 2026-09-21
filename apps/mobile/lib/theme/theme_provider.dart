import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_colors.dart';

class ThemePalette {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color glow;
  final String description;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.glow,
    required this.description,
  });
}

class AppThemeConfig {
  final String paletteId;
  final Color primaryColor;
  final Color accentColor;
  final Color glowColor;

  const AppThemeConfig({
    required this.paletteId,
    required this.primaryColor,
    required this.accentColor,
    required this.glowColor,
  });

  // ONLY the 7 themes requested by user:
  // golden, purple, blue, sea green, #14b8a6, red, pinkish red
  static const List<ThemePalette> predefinedPalettes = [
    ThemePalette(
      id: 'golden',
      name: '👑 Imperial Gold',
      primary: Color(0xFFD4AF37),
      accent: Color(0xFFFFDF00),
      glow: Color(0xFFD4AF37),
      description: 'Atul Residency signature 24K imperial gold and luxury black',
    ),
    ThemePalette(
      id: 'purple',
      name: '🔮 Royal Purple',
      primary: Color(0xFF8B5CF6),
      accent: Color(0xFFC084FC),
      glow: Color(0xFF8B5CF6),
      description: 'Sophisticated royal amethyst with brilliant violet glow',
    ),
    ThemePalette(
      id: 'blue',
      name: '💎 Sapphire Blue',
      primary: Color(0xFF2563EB),
      accent: Color(0xFF60A5FA),
      glow: Color(0xFF2563EB),
      description: 'Deep royal sapphire with dynamic electric blue highlights',
    ),
    ThemePalette(
      id: 'sea_green',
      name: '🌊 Sea Green',
      primary: Color(0xFF00E5BC),
      accent: Color(0xFF5EEAD4),
      glow: Color(0xFF00E5BC),
      description: 'Vibrant luminous sea green with crisp coastal luminescence',
    ),
    ThemePalette(
      id: 'teal',
      name: '🌿 Teal (#14b8a6)',
      primary: Color(0xFF14B8A6),
      accent: Color(0xFF2DD4BF),
      glow: Color(0xFF14B8A6),
      description: 'Atul Residency modern teal accent for crisp professional elegance',
    ),
    ThemePalette(
      id: 'red',
      name: '🔴 Ruby Red',
      primary: Color(0xFFEF4444),
      accent: Color(0xFFF87171),
      glow: Color(0xFFEF4444),
      description: 'Sovereign deep ruby red with striking authority and passion',
    ),
    ThemePalette(
      id: 'pinkish_red',
      name: '🌹 Pinkish Red (Rose Crimson)',
      primary: Color(0xFFE11D48),
      accent: Color(0xFFFB7185),
      glow: Color(0xFFE11D48),
      description: 'Luxurious Parisian rose crimson with refined pinkish red undertones',
    ),
  ];

  static const AppThemeConfig defaultTheme = AppThemeConfig(
    paletteId: 'golden',
    primaryColor: Color(0xFFD4AF37),
    accentColor: Color(0xFFFFDF00),
    glowColor: Color(0xFFD4AF37),
  );

  Color get primaryDark => HSLColor.fromColor(primaryColor)
      .withLightness((HSLColor.fromColor(primaryColor).lightness * 0.65).clamp(0.0, 1.0))
      .toColor();

  Color get primaryLight => HSLColor.fromColor(primaryColor)
      .withLightness((HSLColor.fromColor(primaryColor).lightness * 1.3).clamp(0.0, 1.0))
      .toColor();

  Color get borderGlow => glowColor.withValues(alpha: 0.35);
  Color get glassBorder => primaryColor.withValues(alpha: 0.25);
  Color get glassBackground => Color.lerp(AppColors.bgDark, primaryDark, 0.18)!.withValues(alpha: 0.65);

  ThemeData toThemeData() {
    const bgColor = AppColors.bgDark;
    const cardColor = AppColors.bgCard;
    const textColor = AppColors.textPrimary;
    const textSecColor = AppColors.textSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: AppColors.accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: textColor, fontSize: 15),
        bodyMedium: TextStyle(color: textSecColor, fontSize: 13),
        bodySmall: TextStyle(color: textSecColor, fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none, // BORDERLESS CARDS
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'paletteId': paletteId,
        'primaryColor': primaryColor.value,
        'accentColor': accentColor.value,
        'glowColor': glowColor.value,
      };

  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    return AppThemeConfig(
      paletteId: json['paletteId'] as String? ?? 'golden',
      primaryColor: Color(json['primaryColor'] as int? ?? 0xFFD4AF37),
      accentColor: Color(json['accentColor'] as int? ?? 0xFFFFDF00),
      glowColor: Color(json['glowColor'] as int? ?? 0xFFD4AF37),
    );
  }
}

class ThemeNotifier extends StateNotifier<AppThemeConfig> {
  static const _storageKey = 'chintamani_theme_config';
  final FlutterSecureStorage _storage;

  ThemeNotifier([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(),
        super(AppThemeConfig.defaultTheme) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = AppThemeConfig.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> setPalette(String id) async {
    final match = AppThemeConfig.predefinedPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => AppThemeConfig.predefinedPalettes.first,
    );

    state = AppThemeConfig(
      paletteId: match.id,
      primaryColor: match.primary,
      accentColor: match.accent,
      glowColor: match.glow,
    );

    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      final encoded = jsonEncode(state.toJson());
      await _storage.write(key: _storageKey, value: encoded);
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeConfig>((ref) {
  return ThemeNotifier();
});
