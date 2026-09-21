import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';

class AttentionOverviewCard extends StatelessWidget {
  final DashboardStats stats;

  const AttentionOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final expiringCount = stats.expiringIn1to3Days > 0 ? stats.expiringIn1to3Days : 1;
    final duesAmount = stats.dueAmount > 0 ? stats.dueAmount.toInt() : 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF27272A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Needs Your Attention • View All ->
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Needs Your Attention',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.members),
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item 1: Membership Expiring
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_busy_rounded, color: Color(0xFFEF4444), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$expiringCount Membership Expiring',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Renewal due in 1–3 days',
                      style: TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.members);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                  ),
                  child: const Text(
                    'Renew Now →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF222226), height: 1),
          ),

          // Item 2: Pending Dues
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFF59E0B), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹$duesAmount Pending Dues',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      '1 member overdue',
                      style: TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.recordPayment);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
                  ),
                  child: const Text(
                    'Collect Now →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
