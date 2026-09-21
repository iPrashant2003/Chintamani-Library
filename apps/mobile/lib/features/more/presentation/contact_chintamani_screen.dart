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

class ContactChintaManiScreen extends ConsumerWidget {
  const ContactChintaManiScreen({super.key});

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _callPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    _launchUrl('tel:$clean');
  }

  void _openWhatsApp(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    _launchUrl('https://wa.me/$clean?text=Hello%20Chinta%20Mani%20Library%20Team');
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
              // Top Bar
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
                      const ChintaManiLogo(size: 32, showGlow: true),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Chinta Mani',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Direct Line to Branch Helpdesks',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Contact Branch Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // EXECUTIVE FOUNDER CONTACT CARD (Manglesh Mani Tripathi)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x33D4AF37),
                            Color(0xF2101010),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.goldPrimary, width: 1.4),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.goldGlow,
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  border: Border.all(color: AppColors.goldPrimary, width: 1.2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.workspace_premium_rounded, color: AppColors.goldPrimary, size: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manglesh Mani Tripathi',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    Text(
                                      'Director & Founder • Chinta Mani Library',
                                      style: TextStyle(
                                        color: AppColors.goldPrimary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  'OFFICIAL',
                                  style: TextStyle(color: AppColors.goldLight, fontSize: 9, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            children: [
                              Icon(Icons.phone_android_rounded, color: AppColors.goldPrimary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                '+91 9415919277',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _callPhone('9415919277'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldPrimary,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.call_rounded, size: 16),
                                  label: const Text('Call Director', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openWhatsApp('9415919277'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Khalilabad Branch Contact Card
                    _buildContactCard(
                      branch: Branch.khalilabadBranch,
                      accentColor: theme.primaryColor,
                    ),

                    const SizedBox(height: 16),

                    // Mehdawal Branch Contact Card
                    _buildContactCard(
                      branch: Branch.mehdawalBranch,
                      accentColor: const Color(0xFF38BDF8),
                    ),

                    const SizedBox(height: 20),

                    // General Help & Support info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.headset_mic_rounded, color: Color(0xFFFBBF24), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Support & Enquiries',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Central Helpdesk & Director Hotline: +91 9415919277\nFor seat reservations, locker allocations, and digital membership inquiries for both Khalilabad and Mehdawal branches, please call or WhatsApp during operational hours (06:00 AM – 11:00 PM).',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildContactCard({required Branch branch, required Color accentColor}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xF2121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                      fontSize: 16,
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
                      '● Open 06:00 AM – 11:00 PM',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                branch.subtitle,
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      branch.address,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Phone
              Row(
                children: [
                  const Icon(Icons.phone_outlined, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    branch.phone,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3 Direct Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callPhone(branch.phone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.call_rounded, size: 15),
                      label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(branch.phone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(branch.mapUrl),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: Icon(Icons.navigation_outlined, size: 15, color: accentColor),
                      label: Text('Map', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }
}
