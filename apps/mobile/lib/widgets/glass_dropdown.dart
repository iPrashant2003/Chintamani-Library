import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  const GlassDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              hint: hint != null
                  ? Text(hint!, style: const TextStyle(color: AppColors.textDisabled, fontSize: 14))
                  : null,
              isExpanded: true,
              dropdownColor: AppColors.bgCard,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
