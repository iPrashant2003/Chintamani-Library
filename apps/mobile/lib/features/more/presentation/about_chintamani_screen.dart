import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/theme_provider.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../branch/domain/branch_model.dart';

class AboutChintaManiScreen extends ConsumerWidget {
  const AboutChintaManiScreen({super.key});

  Future<void> _launchDirections(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with Back Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle, width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'About Chinta Mani',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Laurel Logo & Brand Emblem
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor.withValues(alpha: 0.20),
                              AppColors.bgCard.withValues(alpha: 0.90),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: theme.glowColor.withValues(alpha: 0.25),
                              blurRadius: 28,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const ChintaManiLogo(
                              size: 88,
                              showGlow: true,
                              showCircularBackground: true,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'CHINTA MANI LIBRARY',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'Infinity under a roof',
                                style: TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sant Kabir Nagar\'s Premier Academic Self-Study Network',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Vision & Environment Sections
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoCard(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Our Vision',
                      description:
                          'To cultivate an atmosphere of uncompromising academic excellence, discipline, and comfort for students preparing for competitive examinations, civil services, medical, and engineering entrances.',
                      accentColor: theme.primaryColor,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.psychology_outlined,
                      title: 'Our Study Environment',
                      description:
                          'Designed with ergonomic furniture, climate control, acoustic soundproofing, dedicated electrical points, and high-speed fiber internet to ensure complete distraction-free focus.',
                      accentColor: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 18),

                    // Official Branches Heading
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Our Branches',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Khalilabad Branch Card
                    _buildBranchCard(
                      context,
                      Branch.khalilabadBranch,
                      theme.primaryColor,
                    ),
                    const SizedBox(height: 12),

                    // Mehdawal Branch Card
                    _buildBranchCard(
                      context,
                      Branch.mehdawalBranch,
                      const Color(0xFF38BDF8),
                    ),

                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                branch.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '● Open',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            branch.subtitle,
            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  branch.address,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.textTertiary, size: 16),
              const SizedBox(width: 6),
              Text(
                branch.openingHours,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchDirections(branch.mapUrl),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: Icon(Icons.navigation_outlined, size: 15, color: accentColor),
              label: Text('Get Directions', style: TextStyle(color: accentColor, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
