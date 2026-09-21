import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/glass_dropdown.dart';
import '../../../widgets/primary_button.dart';
import '../data/communication_repository.dart';

class CommunicationScreen extends ConsumerStatefulWidget {
  const CommunicationScreen({super.key});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Send message form
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _channel = 'WHATSAPP';
  String _selectedTemplate = 'PAYMENT_REMINDER';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient phone number')),
      );
      return;
    }

    setState(() => _isSending = true);
    await ref.read(communicationRepositoryProvider).sendMessage(
      channel: _channel,
      recipientPhone: _phoneController.text.trim(),
      templateName: _selectedTemplate,
      variables: {
        'name': _nameController.text.trim().isEmpty ? 'Student' : _nameController.text.trim(),
        'amount': '600',
        'date': '12 Sep 2026',
        'memberCode': 'CML-942810',
        'seat': 'A05',
      },
    );

    ref.invalidate(communicationLogsProvider);

    if (mounted) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusActive,
          content: Text('$_channel message dispatched successfully to ${_phoneController.text.trim()}!'),
        ),
      );
      _phoneController.clear();
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(communicationLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Communication Center'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.accentNeon,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Send Message'),
            Tab(text: 'Message History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Send Message
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.send_rounded, color: AppColors.accentNeon, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Send automated SMS and WhatsApp reminders for fees, attendance, and expiry.',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassDropdown<String>(
                  label: 'Delivery Channel',
                  value: _channel,
                  items: const [
                    DropdownMenuItem(value: 'WHATSAPP', child: Text('WhatsApp (Official Template)')),
                    DropdownMenuItem(value: 'SMS', child: Text('SMS Gateway')),
                    DropdownMenuItem(value: 'PUSH', child: Text('Push Notification')),
                  ],
                  onChanged: (v) => setState(() => _channel = v ?? 'WHATSAPP'),
                ),
                const SizedBox(height: 14),
                GlassDropdown<String>(
                  label: 'Message Template',
                  value: _selectedTemplate,
                  items: const [
                    DropdownMenuItem(value: 'PAYMENT_REMINDER', child: Text('Fee Payment Reminder')),
                    DropdownMenuItem(value: 'MEMBERSHIP_EXPIRY', child: Text('Membership Expiry Alert')),
                    DropdownMenuItem(value: 'WELCOME', child: Text('New Member Welcome & Seat')),
                    DropdownMenuItem(value: 'ATTENDANCE_REMINDER', child: Text('Study Streak & Attendance')),
                  ],
                  onChanged: (v) => setState(() => _selectedTemplate = v ?? 'PAYMENT_REMINDER'),
                ),
                const SizedBox(height: 14),
                GlassTextField(
                  controller: _nameController,
                  label: 'Recipient Student Name',
                  hintText: 'e.g. Aarav Sharma',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 14),
                GlassTextField(
                  controller: _phoneController,
                  label: 'Recipient Mobile Number *',
                  hintText: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Send via $_channel',
                  isLoading: _isSending,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),

          // Tab 2: Logs
          logsAsync.when(
            data: (logs) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: log.channel == 'WHATSAPP'
                                    ? AppColors.primaryGreen.withOpacity(0.18)
                                    : const Color(0xFF3B82F6).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.channel,
                                style: TextStyle(
                                  color: log.channel == 'WHATSAPP' ? AppColors.accentNeon : const Color(0xFF3B82F6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(log.recipient, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                            const Spacer(),
                            Text(DateFormat('dd MMM hh:mm a').format(log.createdAt),
                                style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(log.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
            error: (e, _) => Center(child: Text('Error loading logs: $e', style: const TextStyle(color: AppColors.statusExpired))),
          ),
        ],
      ),
    );
  }
}
