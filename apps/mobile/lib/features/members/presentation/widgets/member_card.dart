import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/member_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/member_avatar.dart';
import '../../../../widgets/whatsapp_logo.dart';

class MemberCard extends StatefulWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '08 Sep, 2026';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final seatNum = member.currentSeatNumber ?? '327';
    final planName = member.currentPlanName.isNotEmpty && member.currentPlanName != 'No Plan'
        ? member.currentPlanName
        : '6 hrs batch';
    final batchType = member.batch ?? 'morning~afternoon~even...';
    final sub = member.activeSubscription;
    final joinDate = sub != null ? _formatDate(sub.startDate) : '08 Sep, 2026';
    final expiryDate = sub != null ? _formatDate(sub.endDate) : '07 Oct, 2026';
    final amt = sub?.plan?.price.toInt() ?? 500;
    const paid = 500;
    final due = amt > paid ? amt - paid : 0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _animController.forward();
      },
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgGlass,
                  borderRadius: BorderRadius.circular(18),
                  border: null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Avatar + Name/Location/Phone + Seat Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MemberAvatar(
                          name: member.name,
                          photoUrl: member.photoUrl,
                          isActive: member.isActive,
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      member.address != null && member.address!.isNotEmpty
                                          ? member.address!
                                          : 'moti chauraha khalilabad',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.phone_rounded, size: 12, color: AppColors.primaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    member.phone != null && member.phone!.isNotEmpty
                                        ? member.phone!
                                        : '+91 9682960623',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.save_outlined, size: 12, color: AppColors.textTertiary),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Seat Badge (Red rounded badge matching photo)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626), // Red badge from screenshot
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.chair_alt_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    seatNum,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Inset Details Box (Plan, Type, Join, Expiry, Amt, Paid, Due)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          // Row 1: Plan & Type
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Plan', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      planName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Type', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      batchType,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 2: Join & Expiry
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Join', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      joinDate,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Expiry', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      expiryDate,
                                      style: TextStyle(
                                        color: member.isActive ? AppColors.textPrimary : AppColors.accentRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 3: Amt, Paid, Due
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Amt', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      amt.toString(),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Paid', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      paid.toString(),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Due', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      due.toString(),
                                      style: TextStyle(
                                        color: due > 0 ? AppColors.accentRed : AppColors.primaryGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom 7 Action Buttons (Profile, Bio Enroll, Add Pay, Renew, Add Bill, WhatsApp, Locker)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionBtn(context, Icons.person_rounded, 'Profile', const Color(0xFFDC2626)),
                        _buildActionBtn(context, Icons.fingerprint_rounded, 'Bio Enroll', const Color(0xFFDC2626)),
                        _buildActionBtn(context, Icons.add_card_rounded, 'Add Pay', const Color(0xFFDC2626)),
                        _buildActionBtn(context, Icons.refresh_rounded, 'Renew', const Color(0xFFDC2626)),
                        _buildActionBtn(context, Icons.receipt_long_rounded, 'Add Bill', const Color(0xFFDC2626)),
                        _buildWhatsAppBtn(context),
                        _buildActionBtn(context, Icons.lock_rounded, 'Locker', const Color(0xFFDC2626)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label action for ${widget.member.name}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppBtn(BuildContext context) {
    final member = widget.member;
    final hasPhone = member.phone != null && member.phone!.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        if (!hasPhone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No phone number for this member'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final digits = member.phone!.replaceAll(RegExp(r'[^\d]'), '');
        final fullNum = digits.length == 10 ? '91$digits' : digits;
        final msg = Uri.encodeComponent(
          '🏛️ *CHINTA MANI LIBRARY*\n━━━━━━━━━━━━━━━━━━━━━━\n\n'
          '👤 Dear *${member.name}*,\n\n'
          'This is Chinta Mani Library. Please contact us for any queries.\n\n'
          '📍 *Khalilabad* | *Mehdawal*\n\n'
          '_Chinta Mani Library — Your Study, Our Priority_ 🎯',
        );
        final url = Uri.parse('https://wa.me/$fullNum?text=$msg');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.45), width: 0.8),
            ),
            child: const Center(
              child: WhatsAppLogo(size: 15, color: Color(0xFFFDE68A)),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'WhatsApp',
            style: TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
