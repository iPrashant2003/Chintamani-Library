import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/theme_provider.dart';
import '../../../widgets/ambient_background.dart';

class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final palettes = AppThemeConfig.predefinedPalettes;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'App Theme Preset',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Select your preferred luxury aesthetic',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Active Theme Highlight Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xF2121214),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: currentTheme.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentTheme.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: currentTheme.primaryColor.withValues(alpha: 0.6),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.check_rounded, color: Colors.black, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACTIVE THEME',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              palettes.firstWhere((p) => p.id == currentTheme.paletteId, orElse: () => palettes.first).name,
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 7 Curated Theme Cards List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: palettes.length,
                  itemBuilder: (context, index) {
                    final palette = palettes[index];
                    final isSelected = currentTheme.paletteId == palette.id;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(themeProvider.notifier).setPalette(palette.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Switched to ${palette.name}!',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: palette.primary,
                            duration: const Duration(milliseconds: 1400),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xF2121216),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? palette.primary.withValues(alpha: 0.30) : Colors.black.withValues(alpha: 0.2),
                              blurRadius: isSelected ? 16 : 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Color circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: palette.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primary.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Name & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    palette.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    palette.description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Selection radio
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? palette.primary : Colors.white.withValues(alpha: 0.1),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.black, size: 16)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
