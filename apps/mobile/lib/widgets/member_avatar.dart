import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final bool isActive;

  const MemberAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.isActive = true,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'M';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryTeal.withOpacity(0.35),
          backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
          child: (photoUrl == null || photoUrl!.isEmpty)
              ? Text(
                  initials,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.75,
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.5,
            height: radius * 0.5,
            decoration: BoxDecoration(
              color: isActive ? AppColors.statusActive : AppColors.statusExpired,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bgDark, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
