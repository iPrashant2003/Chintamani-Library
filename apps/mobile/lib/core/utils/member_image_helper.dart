import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/members/domain/member_model.dart';
import '../api/api_endpoints.dart';

/// Centralised member profile image resolver.
///
/// Priority:
///   1. Uploaded selfie (photoUrl on member record, served by backend uploads/ or network/file URL)
///   2. Gender-specific default asset (assets/images/avatar_male.png / assets/images/avatar_female.png)
///   3. Generic safe fallback (assets/images/avatar_male.png)
class MemberImageHelper {
  MemberImageHelper._();

  static const String assetMale = 'assets/images/avatar_male.png';
  static const String assetFemale = 'assets/images/avatar_female.png';

  /// Returns [true] if the member has a photo URL set.
  static bool hasPhoto(Member member) {
    return member.photoUrl != null && member.photoUrl!.trim().isNotEmpty;
  }

  /// Returns [true] if a photo URL string is present and valid.
  static bool isValidPhotoUrl(String? url) {
    return url != null && url.trim().isNotEmpty && url.trim() != 'null';
  }

  /// Formats any photo URL string into a fully-qualified reachable URL.
  static String formatPhotoUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // Relative path — prepend backend base + uploads
    String base = ApiEndpoints.baseUrl.trim();
    while (base.endsWith('/')) base = base.substring(0, base.length - 1);
    String path = trimmed;
    while (path.startsWith('/')) path = path.substring(1);
    if (path.startsWith('uploads/')) {
      return '$base/$path';
    }
    return '$base/uploads/$path';
  }

  /// Returns the full image URL for a member's uploaded photo.
  static String getPhotoUrl(Member member) {
    return formatPhotoUrl(member.photoUrl ?? '');
  }

  /// Asset path for a gender-specific default avatar based on gender string.
  static String getDefaultAssetForGender(String? gender) {
    final g = (gender ?? '').toLowerCase().trim();
    if (g == 'female' || g == 'f' || g == 'girl' || g == 'woman') {
      return assetFemale;
    }
    return assetMale;
  }

  /// Asset path for a gender-specific default avatar for a [Member].
  static String getDefaultAsset(Member member) {
    return getDefaultAssetForGender(member.gender);
  }

  /// Centralized image provider resolver as specified by requirement:
  /// getMemberProfileImage(member)
  /// Returns:
  ///   1. Uploaded selfie, if available.
  ///   2. Otherwise gender-specific default.
  ///   3. Otherwise generic fallback.
  static ImageProvider getMemberProfileImage(Member member) {
    return resolveProfileImage(photoUrl: member.photoUrl, gender: member.gender);
  }

  /// Resolves an [ImageProvider] from raw photoUrl and gender strings.
  static ImageProvider resolveProfileImage({String? photoUrl, String? gender}) {
    if (isValidPhotoUrl(photoUrl)) {
      final url = photoUrl!.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return CachedNetworkImageProvider(url);
      }
      if (url.startsWith('/') && File(url).existsSync()) {
        return FileImage(File(url));
      }
      return CachedNetworkImageProvider(formatPhotoUrl(url));
    }
    return AssetImage(getDefaultAssetForGender(gender));
  }

  /// Returns a circular Flutter [Widget] with the member's profile image.
  /// Handles loading, caching, gender fallback, and initials on error.
  static Widget buildAvatar({
    required Member member,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Color? accentColor,
  }) {
    return buildAvatarFromData(
      photoUrl: member.photoUrl,
      gender: member.gender,
      name: member.name,
      size: size,
      fit: fit,
      errorWidget: errorWidget,
      accentColor: accentColor,
    );
  }

  /// Generalized avatar builder accepting raw attributes.
  static Widget buildAvatarFromData({
    String? photoUrl,
    String? gender,
    required String name,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Color? accentColor,
  }) {
    final fallback = errorWidget ??
        _initialsWidget(name, size, accentColor ?? const Color(0xFFD4AF37));

    if (isValidPhotoUrl(photoUrl)) {
      final fullUrl = formatPhotoUrl(photoUrl!);
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: fullUrl,
          width: size,
          height: size,
          fit: fit,
          placeholder: (ctx, url) => _shimmerPlaceholder(size),
          errorWidget: (ctx, url, err) {
            // Fall through to gender default on network failure
            return ClipOval(
              child: Image.asset(
                getDefaultAssetForGender(gender),
                width: size,
                height: size,
                fit: fit,
                errorBuilder: (_, __, ___) => fallback,
              ),
            );
          },
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        getDefaultAssetForGender(gender),
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static Widget _initialsWidget(String name, double size, Color accent) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'M';
    return Container(
      width: size,
      height: size,
      color: accent.withOpacity(0.15),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: accent,
            fontSize: size * 0.44,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  static Widget _shimmerPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.white.withOpacity(0.06),
    );
  }
}

extension StringCharTrimming on String {
  String trimSuffix(String char) =>
      endsWith(char) ? substring(0, length - char.length) : this;
  String trimPrefix(String char) =>
      startsWith(char) ? substring(char.length) : this;
}
