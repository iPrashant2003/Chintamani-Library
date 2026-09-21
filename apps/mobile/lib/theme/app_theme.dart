import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: AppColors.textTertiary, fontSize: 11),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryTeal,
        surface: AppColors.bgCard,
        error: AppColors.accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.accentNeon,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.accentNeon, fontSize: 11, fontWeight: FontWeight.w700);
          }
          return const TextStyle(color: AppColors.textTertiary, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentNeon);
          }
          return const IconThemeData(color: AppColors.textTertiary);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderEmerald, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }
}
