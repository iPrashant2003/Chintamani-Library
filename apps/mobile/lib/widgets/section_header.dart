import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? leadingIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.accentNeon,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
