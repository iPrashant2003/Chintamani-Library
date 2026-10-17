import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _activeFilter = 'ALL';
  final Set<String> _readIds = {};

  IconData _getIconForType(String type) {
    switch (type) {
      case 'PAYMENT_ALERT':
        return Icons.receipt_long_rounded;
      case 'BACKUP':
        return Icons.backup_rounded;
      case 'UPDATE':
        return Icons.system_update_rounded;
      case 'OPERATIONS':
        return Icons.storefront_rounded;
      case 'PORTAL':
        return Icons.qr_code_scanner_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'PAYMENT_ALERT':
        return const Color(0xFFEF4444);
      case 'BACKUP':
        return const Color(0xFF10B981);
      case 'UPDATE':
        return const Color(0xFF00E5BC);
      case 'OPERATIONS':
        return const Color(0xFFD4AF37);
      case 'PORTAL':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF00E5BC);
    }
  }

  void _onNotificationTap(BuildContext context, AppNotification notif) {
    HapticFeedback.lightImpact();
    setState(() => _readIds.add(notif.id));

    switch (notif.type) {
      case 'PAYMENT_ALERT':
        context.push(RouteNames.duePayments);
        break;
      case 'BACKUP':
        context.push(RouteNames.databaseBackup);
        break;
      case 'UPDATE':
        context.push(RouteNames.appUpdates);
        break;
      case 'OPERATIONS':
        context.push(RouteNames.seats);
        break;
      case 'PORTAL':
        context.push(RouteNames.universalQr);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E12),
        elevation: 0,
        title: const Text(
          'Notifications & Alerts',
          style: TextStyle(
            color: Color(0xFFF3E5AB),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Notifications',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(notificationsListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E12),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Alerts'),
                  const SizedBox(width: 8),
                  _buildFilterChip('PAYMENT_ALERT', 'Dues & Fees'),
                  const SizedBox(width: 8),
                  _buildFilterChip('BACKUP', 'Database'),
                  const SizedBox(width: 8),
                  _buildFilterChip('OPERATIONS', 'Halls & Seats'),
                ],
              ),
            ),
          ),

          // Main Notifications List
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFD4AF37),
              backgroundColor: const Color(0xFF141218),
              onRefresh: () async => ref.invalidate(notificationsListProvider),
              child: notifsAsync.when(
                data: (list) {
                  final filtered = list.where((n) {
                    if (_activeFilter == 'ALL') return true;
                    return n.type == _activeFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF141218),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: const Icon(Icons.notifications_off_rounded, size: 40, color: Color(0xFFD4AF37)),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No notifications in this category',
                            style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Everything is up to date and verified',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final notif = filtered[index];
                      final isRead = notif.isRead || _readIds.contains(notif.id);
                      final typeColor = _getColorForType(notif.type);
                      final icon = _getIconForType(notif.type);

                      return GestureDetector(
                        onTap: () => _onNotificationTap(context, notif),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? const Color(0xFF100F15) : const Color(0xFF16151E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRead
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : typeColor.withValues(alpha: 0.45),
                              width: isRead ? 1.0 : 1.3,
                            ),
                            boxShadow: isRead
                                ? null
                                : [
                                    BoxShadow(
                                      color: typeColor.withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: typeColor.withValues(alpha: 0.35)),
                                ),
                                child: Icon(icon, color: typeColor, size: 20),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            style: TextStyle(
                                              color: isRead ? AppColors.textPrimary : const Color(0xFFFDE68A),
                                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: typeColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      notif.body,
                                      style: TextStyle(
                                        color: isRead ? AppColors.textSecondary : const Color(0xFFD1D5DB),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('hh:mm a • dd MMM').format(notif.createdAt),
                                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Tap to view',
                                              style: TextStyle(
                                                color: typeColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Icon(Icons.chevron_right_rounded, color: typeColor, size: 14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
                error: (e, _) => Center(
                  child: Text('Error loading alerts: $e', style: const TextStyle(color: AppColors.statusExpired)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.18) : const Color(0xFF15141C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFDE68A) : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
