import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum Card3DTheme { gold, blue, red, emerald, purple, dark }

class Card3D extends StatefulWidget {
  final Widget child;
  final Card3DTheme theme;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double maxTilt;
  final bool enableSheen;
  final double elevation;

  const Card3D({
    super.key,
    required this.child,
    this.theme = Card3DTheme.gold,
    this.onTap,
    this.borderRadius = 18,
    this.padding,
    this.maxTilt = 0.08,
    this.enableSheen = true,
    this.elevation = 12,
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  late Animation<Offset> _tiltAnimation;

  Offset _tilt = Offset.zero;
  Offset _sheenPos = const Offset(0.5, 0.5);
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        setState(() {
          _tilt = _tiltAnimation.value;
          _sheenPos = Offset(0.5 + _tilt.dy * 2, 0.5 - _tilt.dx * 2);
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event, BoxConstraints constraints) {
    if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) return;
    final normalizedX = (event.localPosition.dx / constraints.maxWidth) * 2 - 1;
    final normalizedY = (event.localPosition.dy / constraints.maxHeight) * 2 - 1;

    setState(() {
      _tilt = Offset(
        -normalizedY.clamp(-1.0, 1.0) * widget.maxTilt,
        normalizedX.clamp(-1.0, 1.0) * widget.maxTilt,
      );
      _sheenPos = Offset(
        (event.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
        (event.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0),
      );
      _isHovered = true;
    });
  }

  void _onPointerExit() {
    _tiltAnimation = Tween<Offset>(
      begin: _tilt,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    ));
    _resetController.forward(from: 0);
    setState(() => _isHovered = false);
  }

  Color get _borderColor {
    switch (widget.theme) {
      case Card3DTheme.gold:
        return AppColors.goldPrimary.withValues(alpha: _isHovered ? 0.85 : 0.45);
      case Card3DTheme.blue:
        return AppColors.bluePrimary.withValues(alpha: _isHovered ? 0.85 : 0.45);
      case Card3DTheme.red:
        return AppColors.redPrimary.withValues(alpha: _isHovered ? 0.85 : 0.45);
      case Card3DTheme.emerald:
        return AppColors.emeraldPrimary.withValues(alpha: _isHovered ? 0.85 : 0.45);
      case Card3DTheme.purple:
        return AppColors.purplePrimary.withValues(alpha: _isHovered ? 0.85 : 0.45);
      case Card3DTheme.dark:
        return Colors.white.withValues(alpha: _isHovered ? 0.3 : 0.12);
    }
  }

  Color get _glowColor {
    switch (widget.theme) {
      case Card3DTheme.gold:
        return AppColors.goldAccent;
      case Card3DTheme.blue:
        return AppColors.blueAqua;
      case Card3DTheme.red:
        return AppColors.redRuby;
      case Card3DTheme.emerald:
        return AppColors.emeraldPrimary;
      case Card3DTheme.purple:
        return AppColors.purplePrimary;
      case Card3DTheme.dark:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  Color get _tintGradientColor {
    switch (widget.theme) {
      case Card3DTheme.gold:
        return const Color(0x22D4AF37);
      case Card3DTheme.blue:
        return const Color(0x222563EB);
      case Card3DTheme.red:
        return const Color(0x22EF4444);
      case Card3DTheme.emerald:
        return const Color(0x2210B981);
      case Card3DTheme.purple:
        return const Color(0x228B5CF6);
      case Card3DTheme.dark:
        return const Color(0x11FFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (e) => _onPointerMove(e, constraints),
          onExit: (_) => _onPointerExit(),
          child: GestureDetector(
            onPanUpdate: (details) {
              final normX = (details.localPosition.dx / constraints.maxWidth) * 2 - 1;
              final normY = (details.localPosition.dy / constraints.maxHeight) * 2 - 1;
              setState(() {
                _tilt = Offset(
                  -normY.clamp(-1.0, 1.0) * widget.maxTilt,
                  normX.clamp(-1.0, 1.0) * widget.maxTilt,
                );
                _sheenPos = Offset(
                  (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
                  (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0),
                );
                _isHovered = true;
              });
            },
            onPanEnd: (_) => _onPointerExit(),
            onPanCancel: () => _onPointerExit(),
            onTap: widget.onTap,
            child: RepaintBoundary(
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(_tilt.dx)
                  ..rotateY(_tilt.dy),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // Multi-layer glassmorphism background with color undertones
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _glowColor.withValues(alpha: _isHovered ? 0.22 : 0.14),
                        const Color(0xF5141416),
                        const Color(0xFA0A0A0C),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                    border: null, // Borderless luxury card
                    boxShadow: [
                      BoxShadow(
                        color: _glowColor.withValues(alpha: _isHovered ? 0.45 : 0.22),
                        blurRadius: _isHovered ? 26 : 16,
                        spreadRadius: _isHovered ? 2.0 : 0.5,
                        offset: Offset(0, 4 + _tilt.dx * 10),
                      ),
                      const BoxShadow(
                        color: Color(0xC0000000),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Stack(
                      children: [
                        // Luxury crystalline light sweep & glass texture overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-0.8, -1.0),
                                end: Alignment(0.8, 1.0),
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.02),
                                  Colors.transparent,
                                  _glowColor.withValues(alpha: 0.06),
                                ],
                                stops: const [0.0, 0.25, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: widget.padding ?? const EdgeInsets.all(16),
                          child: widget.child,
                        ),
                        // Dynamic 3D specular sheen overlay
                        if (widget.enableSheen && _isHovered)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(
                                      _sheenPos.dx * 2 - 1,
                                      _sheenPos.dy * 2 - 1,
                                    ),
                                    radius: 0.85,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.white.withValues(alpha: 0.02),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
