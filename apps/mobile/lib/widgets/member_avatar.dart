import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/utils/member_image_helper.dart';
import '../features/members/domain/member_model.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? gender;
  final double radius;
  final bool isActive;
  final Member? member;

  const MemberAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.gender,
    this.radius = 20,
    this.isActive = true,
    this.member,
  });

  factory MemberAvatar.fromMember({
    Key? key,
    required Member member,
    double radius = 20,
  }) {
    return MemberAvatar(
      key: key,
      name: member.name,
      photoUrl: member.photoUrl,
      gender: member.gender,
      radius: radius,
      isActive: member.isActive,
      member: member,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primaryTeal : AppColors.statusExpired,
              width: 1.2,
            ),
          ),
          child: member != null
              ? MemberImageHelper.buildAvatar(
                  member: member!,
                  size: size,
                )
              : MemberImageHelper.buildAvatarFromData(
                  photoUrl: photoUrl,
                  gender: gender,
                  name: name,
                  size: size,
                ),
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
