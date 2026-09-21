import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassTheme {
  static BoxDecoration cardDecoration({
    double opacity = 0.05,
    double borderRadius = 16,
    Color? borderColor,
  }) => BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderColor ?? AppColors.primaryGreen.withOpacity(0.2), width: 1),
    boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.05), blurRadius: 20, spreadRadius: 0)],
  );
  
  static const double defaultBlur = 10.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}
