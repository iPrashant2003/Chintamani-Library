import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/glass_theme.dart';

class GlassTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final dynamic prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const GlassTextField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? resolvedPrefix;
    if (prefixIcon != null) {
      if (prefixIcon is IconData) {
        resolvedPrefix = Icon(prefixIcon as IconData, color: Colors.white54);
      } else if (prefixIcon is Widget) {
        resolvedPrefix = prefixIcon as Widget;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: GlassTheme.defaultBlur, sigmaY: GlassTheme.defaultBlur),
            child: Container(
              decoration: GlassTheme.cardDecoration(opacity: 0.1),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                validator: validator,
                keyboardType: keyboardType,
                maxLines: obscureText ? 1 : maxLines,
                onChanged: onChanged,
                readOnly: readOnly,
                onTap: onTap,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: resolvedPrefix,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
