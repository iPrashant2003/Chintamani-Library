import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? iconColor;
  final Color? valueColor;
  final Color? badgeBgColor;
  final VoidCallback? onTap;
  final bool hasRedDot;
  final bool isCustomWidget;
  final Widget? customCenterWidget;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.iconColor,
    this.valueColor,
    this.badgeBgColor,
    this.onTap,
    this.hasRedDot = false,
    this.isCustomWidget = false,
    this.customCenterWidget,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
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
    final goldIcon = widget.iconColor ?? const Color(0xFFE5C07B);
    final badgeBg = widget.badgeBgColor ?? const Color(0xFF242016);
    final valColor = widget.valueColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _animController.forward();
      },
      onTapUp: (_) {
        _animController.reverse();
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF151518),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF242428),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Circular Icon Badge + Optional Red Alert Dot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(widget.icon, color: goldIcon, size: 15),
                    ),
                  ),
                  if (widget.hasRedDot)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFEF4444),
                            blurRadius: 5,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 7, height: 7),
                ],
              ),

              // Middle: Metric Value or Custom Mini Widget
              if (widget.isCustomWidget && widget.customCenterWidget != null)
                widget.customCenterWidget!
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.value ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: valColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

              // Bottom: Label
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD4D4D8),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
