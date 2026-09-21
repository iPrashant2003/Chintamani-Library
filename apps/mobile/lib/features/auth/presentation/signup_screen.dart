import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../branch/domain/branch_model.dart';
import '../../branch/providers/branch_provider.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedBranch = 'Khalilabad';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    HapticFeedback.lightImpact();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and mobile number'),
          backgroundColor: AppColors.redPrimary,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).signup(
          name: name,
          phone: phone,
          email: email.isEmpty ? '$phone@chintamani.com' : email,
          password: password,
          branch: _selectedBranch,
        );

    // Set branch
    if (_selectedBranch == 'Mehdawal') {
      ref.read(activeBranchProvider.notifier).state = Branch.mehdawalBranch;
    } else {
      ref.read(activeBranchProvider.notifier).state = Branch.khalilabadBranch;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Logo
                  const ChintaManiLogo(
                    size: 80,
                    showGlow: true,
                    showCircularBackground: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CHINTA MANI LIBRARY',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'New Scholar & Staff Registration',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3D Registration Card in Imperial Gold
                  Card3D(
                    theme: Card3DTheme.gold,
                    borderRadius: 22,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create Your Profile',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Saved permanently on this device — no repeated logins required',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.goldPrimary, size: 18),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mobile Number
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.goldPrimary, size: 18),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Branch Selector Segment
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedBranch = 'Khalilabad'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedBranch == 'Khalilabad'
                                          ? AppColors.goldPrimary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Khalilabad',
                                        style: TextStyle(
                                          color: _selectedBranch == 'Khalilabad'
                                              ? Colors.black
                                              : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedBranch = 'Mehdawal'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedBranch == 'Mehdawal'
                                          ? AppColors.goldPrimary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Mehdawal (Digital)',
                                        style: TextStyle(
                                          color: _selectedBranch == 'Mehdawal'
                                              ? Colors.black
                                              : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Optional Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Email Address (Optional)',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.blueAqua, size: 18),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.blueAqua, width: 1.4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.goldGlow,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text(
                                  'Register & Enter Library',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Already Have an Account? Link to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.login),
                        child: const Text(
                          'Sign In Directly',
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Developer Credit Footer
                  const Text(
                    'Developed by Prashant Mani Tripathi',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
