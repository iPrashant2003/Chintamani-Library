import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryGreen;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: effectiveColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: effectiveColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
