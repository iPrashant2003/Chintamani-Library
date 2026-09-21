import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../theme/app_colors.dart';

class BranchSwitcher extends ConsumerWidget {
  final bool onCoral;
  const BranchSwitcher({super.key, this.onCoral = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final branchesAsync = ref.watch(userBranchesProvider);
    final branches = branchesAsync.value ?? Branch.defaultBranches;
    final currentBranch = activeBranch;
    final branchDisplayName = currentBranch.name.contains(' – ')
        ? currentBranch.name.split(' – ').last
        : currentBranch.name;

    return PopupMenuButton<Branch>(
      initialValue: currentBranch,
      onSelected: (branch) {
        ref.read(activeBranchProvider.notifier).state = branch;
      },
      color: AppColors.bgCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderEmerald, width: 1.2),
      ),
      itemBuilder: (context) => branches.map((b) {
        final isSelected = b.id == currentBranch.id;
        return PopupMenuItem<Branch>(
          value: b,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: isSelected ? AppColors.accentNeon : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  b.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.accentNeon : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, size: 18, color: AppColors.accentNeon),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderEmerald,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.accentNeon,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentNeon,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                branchDisplayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textGreen,
            ),
          ],
        ),
      ),
    );
  }
}
