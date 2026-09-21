import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailing,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
