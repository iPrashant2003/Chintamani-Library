import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? glowColor;
  final Color? backgroundColor;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.onTap,
    this.borderColor,
    this.glowColor,
    this.backgroundColor,
    this.blur = 12.0,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(18);
    final effectiveBorderColor = widget.borderColor ?? AppColors.borderEmerald;
    final effectiveGlowColor = widget.glowColor ?? AppColors.primaryGreen.withValues(alpha: 0.06);
    final effectiveBgColor = widget.backgroundColor ?? AppColors.bgGlass;

    Widget content = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveGlowColor.withValues(alpha: 0.16),
                effectiveBgColor,
                const Color(0xF20F0F12),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            borderRadius: effectiveRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveGlowColor,
                blurRadius: 22,
                spreadRadius: 1.0,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Color(0x70000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _animController.forward();
        },
        onTapUp: (_) {
          _animController.reverse();
          widget.onTap!();
        },
        onTapCancel: () => _animController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: content,
        ),
      );
    }

    if (widget.margin != null) {
      return Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    return content;
  }
}
