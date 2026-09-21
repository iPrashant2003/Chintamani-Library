import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: const TextStyle(
                color: AppColors.accentNeon,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (currentStep <= stepLabels.length)
              Text(
                stepLabels[currentStep - 1],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep - 1;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : isCurrent
                          ? AppColors.accentNeon
                          : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isCompleted || isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
