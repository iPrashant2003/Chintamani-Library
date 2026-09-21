import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              child: PrimaryButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
