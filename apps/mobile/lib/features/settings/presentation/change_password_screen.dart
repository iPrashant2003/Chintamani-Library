import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

/// Dedicated standalone screen for changing the app admin password.
class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.goldPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change App Password',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0x22D4AF37)),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _ChangePasswordBody(),
      ),
    );
  }
}

class _ChangePasswordBody extends ConsumerStatefulWidget {
  const _ChangePasswordBody();

  @override
  ConsumerState<_ChangePasswordBody> createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends ConsumerState<_ChangePasswordBody> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final old = _oldPass.text.trim();
    final nw = _newPass.text.trim();
    final cf = _confirmPass.text.trim();

    if (old.isEmpty || nw.isEmpty || cf.isEmpty) {
      _snack('All fields are required', isError: true);
      return;
    }
    if (nw != cf) {
      _snack('New passwords do not match', isError: true);
      return;
    }
    if (nw.length < 4) {
      _snack('Password must be at least 4 characters', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).changePassword(old, nw);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _oldPass.clear();
      _newPass.clear();
      _confirmPass.clear();
      _snack('✅ Password changed successfully!', isError: false);
    } else {
      _snack('❌ Incorrect current password. Try again.', isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFFDC2626), size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Password',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'This password is used to unlock the Chinta Mani Library admin panel. Keep it safe.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Fields
        _label('Current Password'),
        const SizedBox(height: 8),
        _PassField(controller: _oldPass, label: 'Enter current password'),
        const SizedBox(height: 20),

        _label('New Password'),
        const SizedBox(height: 8),
        _PassField(controller: _newPass, label: 'Enter new password'),
        const SizedBox(height: 20),

        _label('Confirm New Password'),
        const SizedBox(height: 8),
        _PassField(controller: _confirmPass, label: 'Re-enter new password'),
        const SizedBox(height: 36),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2.5),
                )
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.lock_reset_rounded, size: 20),
                  label: const Text(
                    'Update Password',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _submit,
                ),
        ),
        const SizedBox(height: 16),

        // Hint
        const Center(
          child: Text(
            'Default password: CML6050 (if not changed)',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _PassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const _PassField({required this.controller, required this.label});

  @override
  State<_PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<_PassField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_visible,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x22FFFFFF))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(_visible ? Icons.visibility_off : Icons.visibility, color: AppColors.textTertiary, size: 18),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}
